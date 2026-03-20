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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Troubleshooting', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    const SizedBox(height: 4),
                    const Text('Diagnose and resolve device issues', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('0 Issues Detected', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 180, // fixed height for troubleshooting cards
            ),
            itemCount: _destinations.length,
            itemBuilder: (context, index) {
              final dev = _destinations[index];
              final isOnline = dev['status'] == 'Online';
              final isSelected = dev['id'] == _selectedDeviceId;
              return GestureDetector(
                onTap: () => setState(() => _selectedDeviceId = dev['id'] as String),
                child: AvCard(
                  padding: EdgeInsets.zero,
                  isSelected: isSelected,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isOnline ? AppTheme.primaryPurple.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.router, 
                              color: isOnline ? AppTheme.primaryPurple : Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dev['name']!, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    AvBadge(
                                      text: dev['status']!, 
                                      color: isOnline ? Colors.green : Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        dev['location']!, 
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'IP: ${dev['ip']}', 
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.analytics_outlined, size: 16),
                          label: const Text('Run Diagnostics'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isSelected ? Colors.white : AppTheme.primaryPurple,
                            backgroundColor: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                            side: const BorderSide(color: AppTheme.primaryPurple),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
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
