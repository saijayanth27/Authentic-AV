import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/device_model.dart';
import '../modules/discovery_module.dart';

/// Discovers AV-over-IP devices using the ASPEED node_query command.
///
/// Strategy:
///   1. Read the device's own IP to determine the local subnet.
///   2. Send `node_query --dump --json` to all 254 IPs simultaneously.
///   3. The FIRST ASPEED device that responds returns ALL connected devices.
///   4. If auto-scan fails, a fallback manual IP can be used.
class NodeQueryService {
  static const String _command = 'node_query --dump';
  static const int _timeoutMs = 10000; // node_query scans network — needs up to 10s

  // ── Network Detection ──────────────────────────────────────────────────────

  /// Returns the local IPv4 address of this device on the LAN.
  static Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (!addr.isLoopback && !ip.startsWith('169.254')) {
            return ip;
          }
        }
      }
    } catch (e) {
      debugPrint('NodeQueryService: getLocalIp error: $e');
    }
    return null;
  }

  /// Extracts subnet: "192.168.1.105" → "192.168.1"
  static String _subnet(String ip) {
    final parts = ip.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}';
  }

  // ── Device Communication ───────────────────────────────────────────────────

  /// Sends node_query --dump to [ip].
  /// Returns the parsed response map on success, null otherwise.
  /// Writes a human-readable debug line to [debugOut] for display in UI.
  static Future<Map<String, dynamic>?> _runNodeQuery(
    String ip, {
    StringBuffer? debugOut,
  }) async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final uri = Uri.http(ip, '/cgi-bin/query.cgi', {
        'cache': 'false',
        'nocache': ts,
        'cmd': _command,
        'wrap_type': 'multi_line',
        '_': ts,
      });

      final response = await http
          .get(uri)
          .timeout(Duration(milliseconds: _timeoutMs));

      final rawPreview = response.body.length > 400
          ? response.body.substring(0, 400)
          : response.body;

      debugOut?.writeln('STATUS: ${response.statusCode}');
      debugOut?.writeln('RAW RESPONSE:\n$rawPreview');

      if (response.statusCode != 200) {
        debugOut?.writeln('FAIL: status != 200');
        return null;
      }

      // Handle both JSONP: jQuery123({...});  and plain JSON: {...}
      String body = response.body.trim();
      if (body.contains('(') && body.endsWith(');')) {
        body = body.substring(body.indexOf('(') + 1, body.lastIndexOf(')'));
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final result = json['_result'] as String? ?? 'unknown';
      final stdout = json['stdout'] as String? ?? '';
      debugOut?.writeln('_result: $result');
      debugOut?.writeln('stdout:\n$stdout');

      if (result != 'pass') {
        debugOut?.writeln('FAIL: _result is not pass');
        return null;
      }
      return json;
    } catch (e) {
      debugOut?.writeln('ERROR: $e');
      return null;
    }
  }

  // ── Response Parsing ───────────────────────────────────────────────────────

  /// Parses the node_query --dump stdout into DiscoveredDevice objects.
  ///
  /// The device returns a custom text format — NOT JSON.
  /// Each device block is separated by >>>>>> and contains KEY=VALUE lines.
  ///
  /// Example:
  ///   >>>>>>STATE=s_srv_on
  ///   UUID_MAC=44:7C:AC:02:00:14
  ///   MY_IP=192.168.1.22
  ///   HOSTNAME=VRX-001
  ///   >>>>>>STATE=s_srv_on
  ///   UUID_MAC=44:7C:AC:01:00:13
  ///   MY_IP=192.168.1.31
  ///   HOSTNAME=VTX-001
  static List<DiscoveredDevice> _parseResponse(Map<String, dynamic> json) {
    final stdout = (json['stdout'] as String? ?? '').trim();
    if (stdout.isEmpty) return [];
    return _parseTextOutput(stdout);
  }

  /// Parses the multi-device text output from node_query --dump.
  static List<DiscoveredDevice> _parseTextOutput(String stdout) {
    final devices = <DiscoveredDevice>[];
    final seenIps = <String>{};
    final macRe = RegExp(r'[0-9A-Fa-f]{2}(?:[:\-][0-9A-Fa-f]{2}){5}');
    final ipRe   = RegExp(r'\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b');

    // ── Normalise: handle both real newlines AND literal \n in the string ──────
    final normalised = stdout
        .replaceAll('\\n', '\n')   // literal backslash-n → real newline
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    // ── Find the best block separator ─────────────────────────────────────────
    // Try decreasing numbers of > (device blocks look like >>>>>>STATE=...)
    List<String> blocks = [];
    for (int n = 12; n >= 2; n--) {
      final sep = '>' * n;
      if (normalised.contains(sep)) {
        final b = normalised.split(sep)
            .where((s) => s.trim().isNotEmpty)
            .toList();
        if (b.length > blocks.length) blocks = b;
        if (blocks.length > 1) break;
      }
    }
    // Fallback: split at every STATE= boundary
    if (blocks.length <= 1) {
      blocks = normalised
          .split(RegExp(r'\n(?=STATE=)'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    // Last resort: whole stdout as single block
    if (blocks.isEmpty) blocks = [normalised];

    for (final block in blocks) {
      // Build KEY→VALUE map from every line
      final fields = <String, String>{};
      for (final line in block.split('\n')) {
        final eq = line.indexOf('=');
        if (eq < 1) continue;
        final key = line.substring(0, eq).trim().toUpperCase();
        final val = line.substring(eq + 1).trim();
        if (key.isNotEmpty && val.isNotEmpty) fields[key] = val;
      }

      // ── IP ───────────────────────────────────────────────────────────────────
      String ip = '';
      for (final name in ['MY_IP', 'IP', 'NODEIP', 'NODE_IP', 'MANAGE_IP', 'IPADDR']) {
        if (fields.containsKey(name) && ipRe.hasMatch(fields[name]!)) {
          ip = fields[name]!;
          break;
        }
      }
      if (ip.isEmpty) {
        final m = ipRe.firstMatch(block);
        if (m != null) ip = m.group(0)!;
      }
      if (ip.isEmpty || ip == '0.0.0.0' || seenIps.contains(ip)) continue;
      seenIps.add(ip);

      // ── MAC ──────────────────────────────────────────────────────────────────
      final mac = fields['MY_MAC'] ?? fields['UUID_MAC'] ?? fields['MAC']
          ?? macRe.firstMatch(block)?.group(0) ?? 'N/A';

      // ── Hostname ─────────────────────────────────────────────────────────────
      String hostname = '';
      for (final key in fields.keys) {
        if (key.contains('HOSTNAME') || key == 'NAME' || key == 'NODENAME') {
          hostname = fields[key]!;
          if (hostname.isNotEmpty) break;
        }
      }

      // ── TX or RX — determined by IS_HOST field from node_query response ──────
      // IS_HOST=y → Transmitter (TX),  IS_HOST=n → Receiver (RX)
      final isHost = (fields['IS_HOST'] ?? 'n').trim().toLowerCase();
      final DeviceType type = isHost == 'y' ? DeviceType.tx : DeviceType.rx;

      devices.add(DiscoveredDevice(
        name: hostname.isNotEmpty
            ? hostname
            : '${type == DeviceType.tx ? "TX" : "RX"}-$ip',
        ip: ip,
        mac: mac,
        signal: 100,
        type: type,
      ));
    }

    return devices;
  }

  // ── Main Discovery Entry Point ─────────────────────────────────────────────

  /// Discovers all AV devices on the local network.
  ///
  /// If [fallbackIp] is provided (manual entry), it queries that IP directly.
  /// Otherwise, auto-detects the subnet and scans all 254 IPs in parallel.
  /// [onDebug] receives a raw debug string when scan fails — shown in the UI.
  static Future<List<DiscoveredDevice>> discover({
    String? fallbackIp,
    void Function(String status)? onStatus,
    void Function(String debug)? onDebug,
  }) async {
    // ── Manual/fallback IP path ──────────────────────────────────────────────
    if (fallbackIp != null && fallbackIp.isNotEmpty) {
      onStatus?.call('Querying $fallbackIp...');
      final debugOut = StringBuffer();
      debugOut.writeln('--- Query: $fallbackIp ---');
      final result = await _runNodeQuery(fallbackIp, debugOut: debugOut);
      if (result != null) {
        final stdout = (result['stdout'] as String? ?? '').trim();
        debugOut.writeln('stdout length: ${stdout.length} chars');
        debugOut.writeln('stdout preview:\n${stdout.substring(0, stdout.length.clamp(0, 500))}');
        final devices = _parseResponse(result);
        debugOut.writeln('\nPARSED ${devices.length} devices:');
        for (final d in devices) {
          debugOut.writeln('  ${d.type == DeviceType.tx ? "TX" : "RX"} | ${d.ip} | ${d.name}');
        }
        if (devices.isNotEmpty) return devices;
      }
      onDebug?.call(debugOut.toString());
      onStatus?.call('Device at $fallbackIp did not respond.');
      return [];
    }

    // ── Auto-detect subnet ───────────────────────────────────────────────────
    onStatus?.call('Detecting network...');
    final localIp = await getLocalIp();
    if (localIp == null) {
      onDebug?.call('ERROR: Could not read local IP from network interfaces.');
      onStatus?.call('No network. Check WiFi connection.');
      return [];
    }

    final subnet = _subnet(localIp);
    onStatus?.call('Scanning $subnet.x... (phone IP: $localIp)');

    // ── Probe all 254 IPs simultaneously ─────────────────────────────────────
    final ips = List.generate(254, (i) => '$subnet.${i + 1}');
    final results = await Future.wait(ips.map((ip) => _runNodeQuery(ip)));

    // ── Use first successful result ──────────────────────────────────────────
    for (final result in results) {
      if (result != null) {
        final devices = _parseResponse(result);
        if (devices.isNotEmpty) {
          debugPrint('NodeQueryService: found ${devices.length} devices.');
          return devices;
        }
      }
    }

    onStatus?.call('No AV devices found on $subnet.x');
    return [];
  }
}
