import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';

enum DeviceType { rx, tx, unknown }
enum AdoptStatus { pending, adopting, adopted }

class DiscoveredDevice {
  final String name;
  final String ip;
  final String mac;
  final int signal;
  final DeviceType type;
  AdoptStatus status;

  DiscoveredDevice({
    required this.name,
    required this.ip,
    required this.mac,
    required this.signal,
    required this.type,
    this.status = AdoptStatus.pending,
  });
}

class DiscoveryModule extends StatefulWidget {
  const DiscoveryModule({super.key});
  @override
  State<DiscoveryModule> createState() => _DiscoveryModuleState();
}

class _DiscoveryModuleState extends State<DiscoveryModule>
    with TickerProviderStateMixin {
  bool _isScanning = false;
  String _filterType = 'All';
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<DiscoveredDevice> _devices = [
    DiscoveredDevice(name: 'AV-RX-Lobby', ip: '192.168.1.50', mac: '00:1A:2B:3C:4D:5E', signal: 87, type: DeviceType.rx),
    DiscoveredDevice(name: 'AV-TX-Rack1', ip: '192.168.1.51', mac: '00:1A:2B:3C:4D:5F', signal: 62, type: DeviceType.tx),
    DiscoveredDevice(name: 'AV-RX-Kitchen', ip: '192.168.1.52', mac: '00:1A:2B:3C:4D:60', signal: 95, type: DeviceType.rx, status: AdoptStatus.adopted),
    DiscoveredDevice(name: 'AV-TX-Server', ip: '192.168.1.53', mac: '00:1A:2B:3C:4D:61', signal: 44, type: DeviceType.tx),
    DiscoveredDevice(name: 'Unknown Device', ip: '192.168.1.54', mac: '00:1A:2B:3C:4D:62', signal: 30, type: DeviceType.unknown),
  ];

  List<DiscoveredDevice> get _filteredDevices {
    if (_filterType == 'RX') return _devices.where((d) => d.type == DeviceType.rx).toList();
    if (_filterType == 'TX') return _devices.where((d) => d.type == DeviceType.tx).toList();
    if (_filterType == 'Unknown') return _devices.where((d) => d.type == DeviceType.unknown).toList();
    return _devices;
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    // Simulate finding a new device
    setState(() {
      _isScanning = false;
      if (!_devices.any((d) => d.ip == '192.168.1.55')) {
        _devices.add(DiscoveredDevice(
          name: 'AV-RX-Pool',
          ip: '192.168.1.55',
          mac: '00:1A:2B:3C:4D:63',
          signal: 71,
          type: DeviceType.rx,
        ));
      }
    });
  }

  Future<void> _adoptDevice(DiscoveredDevice dev) async {
    setState(() => dev.status = AdoptStatus.adopting);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => dev.status = AdoptStatus.adopted);
  }

  Color _signalColor(int signal) {
    if (signal >= 75) return Colors.greenAccent;
    if (signal >= 45) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  IconData _typeIcon(DeviceType type) {
    switch (type) {
      case DeviceType.rx: return Icons.monitor_rounded;
      case DeviceType.tx: return Icons.cast_rounded;
      case DeviceType.unknown: return Icons.device_unknown_rounded;
    }
  }

  String _typeLabel(DeviceType type) {
    switch (type) {
      case DeviceType.rx: return 'RX';
      case DeviceType.tx: return 'TX';
      case DeviceType.unknown: return '?';
    }
  }

  Color _typeColor(DeviceType type) {
    switch (type) {
      case DeviceType.rx: return Colors.blueAccent;
      case DeviceType.tx: return Colors.purpleAccent;
      case DeviceType.unknown: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _devices.length;
    final adopted = _devices.where((d) => d.status == AdoptStatus.adopted).length;
    final pending = total - adopted;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Device Discovery',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    const SizedBox(height: 4),
                    Text('Scan the network for AVoIP hardware',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              _buildScanButton(),
            ],
          ),
          const SizedBox(height: 20),

          // ── Stats Row ───────────────────────────────────────────────────────
          Row(
            children: [
              _statTile(Icons.devices_rounded, total.toString(), 'Found', Colors.blue.shade300),
              const SizedBox(width: 10),
              _statTile(Icons.check_circle_rounded, adopted.toString(), 'Adopted', Colors.greenAccent),
              const SizedBox(width: 10),
              _statTile(Icons.pending_rounded, pending.toString(), 'Pending', Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 20),

          // ── Radar Animation (when scanning) ─────────────────────────────────
          if (_isScanning) _buildRadar(),
          if (_isScanning) const SizedBox(height: 20),

          // ── Filter Chips ─────────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'RX', 'TX', 'Unknown'].map((f) {
                final selected = _filterType == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterType = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Colors.greenAccent : Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? Colors.greenAccent : Colors.grey.shade800),
                      ),
                      child: Text(f,
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Device List ───────────────────────────────────────────────────────
          if (_filteredDevices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade700),
                    const SizedBox(height: 12),
                    Text('No devices found', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Tap "Start Scan" to search', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_filteredDevices.length, (i) => _buildDeviceCard(_filteredDevices[i])),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _isScanning ? null : _startScan,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isScanning ? Colors.grey.shade800 : Colors.greenAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isScanning)
              const SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            else
              const Icon(Icons.radar_rounded, size: 16, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              _isScanning ? 'Scanning...' : 'Start Scan',
              style: TextStyle(
                color: _isScanning ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildRadar() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              painter: _RadarPainter(_pulseAnim.value),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(DiscoveredDevice dev) {
    final isAdopted = dev.status == AdoptStatus.adopted;
    final isAdopting = dev.status == AdoptStatus.adopting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdopted ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.grey.shade800,
          width: isAdopted ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type badge icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _typeColor(dev.type).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon(dev.type), color: _typeColor(dev.type), size: 22),
                ),
                const SizedBox(width: 14),
                // Name and IP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              dev.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _typeColor(dev.type).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_typeLabel(dev.type),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _typeColor(dev.type))),
                          ),
                          if (isAdopted) ...[ 
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle_rounded, size: 14, color: Colors.greenAccent),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(dev.ip, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                // Signal strength
                Column(
                  children: [
                    Text('${dev.signal}%',
                        style: TextStyle(color: _signalColor(dev.signal), fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Icon(Icons.signal_wifi_4_bar_rounded, size: 14, color: _signalColor(dev.signal)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // MAC + Divider
            Row(
              children: [
                Icon(Icons.memory_rounded, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('MAC: ${dev.mac}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                const Spacer(),
                // Signal bar mini
                _SignalBars(signal: dev.signal),
              ],
            ),
            const SizedBox(height: 12),
            // Signal progress + Adopt button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Signal Strength', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: dev.signal / 100,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(_signalColor(dev.signal)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 36,
                  child: isAdopted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Adopted ✓',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      : ElevatedButton(
                          onPressed: isAdopting ? null : () => _adoptDevice(dev),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isAdopting
                              ? const SizedBox(width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Text('Adopt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _SignalBars extends StatelessWidget {
  final int signal;
  const _SignalBars({required this.signal});
  @override
  Widget build(BuildContext context) {
    Color color = signal >= 75 ? Colors.greenAccent : (signal >= 45 ? Colors.orangeAccent : Colors.redAccent);
    return Row(
      children: List.generate(4, (i) {
        final active = signal >= (i + 1) * 25;
        return Container(
          margin: const EdgeInsets.only(left: 2),
          width: 4,
          height: 6.0 + i * 3,
          decoration: BoxDecoration(
            color: active ? color : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    // Background circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        maxR * i / 3,
        Paint()
          ..color = Colors.greenAccent.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Sweeping arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.transparent, Colors.greenAccent.withValues(alpha: 0.4)],
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi * progress,
      ).createShader(Rect.fromCircle(center: center, radius: maxR))
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxR),
      -pi / 2,
      2 * pi * progress,
      true,
      sweepPaint,
    );

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.greenAccent);

    // Pulsing dot at edge of sweep
    final angle = -pi / 2 + 2 * pi * progress;
    final dotPos = Offset(center.dx + maxR * cos(angle), center.dy + maxR * sin(angle));
    canvas.drawCircle(dotPos, 4, Paint()..color = Colors.greenAccent.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress;
}
