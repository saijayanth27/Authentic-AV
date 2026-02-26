import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DiscoveryModule extends StatefulWidget {
  const DiscoveryModule({super.key});

  @override
  State<DiscoveryModule> createState() => _DiscoveryModuleState();
}

class _DiscoveryModuleState extends State<DiscoveryModule> {
  bool _isScanning = false;

  final List<Map<String, String>> _discoveredDevices = [
    {'name': 'Unknown RX', 'ip': '192.168.1.50', 'mac': '00:1A:2B:3C:4D:5E'},
    {'name': 'Generic TX', 'ip': '192.168.1.51', 'mac': '00:1A:2B:3C:4D:5F'},
  ];

  void _startScan() {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Discovery', 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Scan the network for new AVoIP hardware', 
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _startScan,
                icon: _isScanning 
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.refresh, size: 18),
                label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _discoveredDevices.length,
            itemBuilder: (context, index) {
              final dev = _discoveredDevices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AvCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.settings_input_component, color: AppTheme.primaryTeal),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev['name']!, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'IP: ${dev['ip']} | MAC: ${dev['mac']}', 
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryTeal),
                          foregroundColor: AppTheme.primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Adopt Device'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
