import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Sends the AV routing command to real hardware devices.
///
/// Exact URL (captured from browser DevTools):
///   http://[device_ip]/cgi-bin/query.cgi?cache=false&nocache=[ts]&cmd=e+e_reconnect%3A%3A0031&wrap_type=multi_line&_=[ts]
///
/// Success response: { "stdout": "", "_result": "pass" }
class AVCommandService {
  static const String _command = 'e e_reconnect::0031';

  /// Sends the reconnect command to a single device by IP address.
  static Future<bool> _sendCommandToDevice(String deviceIp) async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final uri = Uri.http(deviceIp, '/cgi-bin/query.cgi', {
        'cache': 'false',
        'nocache': ts,
        'cmd': _command,
        'wrap_type': 'multi_line',
        '_': ts,
      });
      debugPrint('AV → $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      debugPrint('AV ← [${response.statusCode}] ${response.body}');

      if (response.statusCode != 200) return false;

      // Response is JSONP: jQuery...({"stdout":"","_result":"pass"});
      // Strip the JSONP wrapper to get plain JSON
      String body = response.body.trim();
      if (body.contains('(') && body.endsWith(');')) {
        body = body.substring(body.indexOf('(') + 1, body.lastIndexOf(')'));
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['_result'] == 'pass';
    } catch (e) {
      debugPrint('AV command failed for $deviceIp: $e');
      return false;
    }
  }

  /// Routes video from a transmitter to a receiver.
  /// Fires the command to both TX and RX simultaneously.
  static Future<bool> routeVideo({
    required String txIp,
    required String rxIp,
  }) async {
    final results = await Future.wait([
      _sendCommandToDevice(txIp),
      _sendCommandToDevice(rxIp),
    ]);
    return results.every((r) => r);
  }
}
