import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ConfigurationModule extends StatelessWidget {
  const ConfigurationModule({super.key});

  final List<Map<String, String>> _devices = const [
    {'name': 'ESPN Feed', 'ip': '192.168.1.101', 'type': 'TX'},
    {'name': 'YouTube TV', 'ip': '192.168.1.102', 'type': 'TX'},
    {'name': 'Bar Left', 'ip': '192.168.1.201', 'type': 'RX'},
    {'name': 'Bar Right', 'ip': '192.168.1.202', 'type': 'RX'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
          const SizedBox(height: 4),
          const Text('Edit device settings, names, and network parameters', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
            ),
            itemCount: _devices.length,
            itemBuilder: (context, index) {
              final dev = _devices[index];
              return AvCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        dev['type'] == 'TX' ? Icons.settings_input_component : Icons.tv,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dev['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('IP: ${dev['ip']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_note, color: AppTheme.primaryPurple),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
