import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TroubleshootingModule extends StatefulWidget {
  const TroubleshootingModule({super.key});

  @override
  State<TroubleshootingModule> createState() => _TroubleshootingModuleState();
}

class _TroubleshootingModuleState extends State<TroubleshootingModule> {
  String? _selectedDeviceId;

  final List<Map<String, dynamic>> _destinations = [
    {'id': 'rx1', 'name': 'Bar Display 1', 'location': 'Main Bar', 'ip': '192.168.1.201', 'status': 'Online'},
    {'id': 'rx2', 'name': 'Bar Display 2', 'location': 'Main Bar', 'ip': '192.168.1.202', 'status': 'Online'},
    {'id': 'rx3', 'name': 'Lobby Screen', 'location': 'Lobby', 'ip': '192.168.1.203', 'status': 'Online'},
    {'id': 'rx4', 'name': 'Patio Display', 'location': 'Outdoor Patio', 'ip': '192.168.1.204', 'status': 'Online'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Troubleshooting', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
          const SizedBox(height: 4),
          const Text('Diagnose and resolve device issues', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _destinations.length,
            itemBuilder: (context, index) {
              final dev = _destinations[index];
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
                        child: const Icon(Icons.tv, color: AppTheme.primaryTeal),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev['name']!, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Location: ${dev['location']} | IP: ${dev['ip']}', 
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Run Diagnosis'),
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
