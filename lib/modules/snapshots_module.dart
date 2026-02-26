import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SnapshotsModule extends StatelessWidget {
  const SnapshotsModule({super.key});

  final List<Map<String, dynamic>> _snapshots = const [
    {'title': 'Game Day Setup', 'sources': 8, 'destinations': 12},
    {'title': 'Morning Lobby', 'sources': 2, 'destinations': 4},
    {'title': 'VIP All-Clear', 'sources': 0, 'destinations': 6},
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Routing Snapshots', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    SizedBox(height: 4),
                    Text('Save and recall frequent routing setups', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Snapshot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.4,
            ),
            itemCount: _snapshots.length,
            itemBuilder: (context, index) {
              final snapshot = _snapshots[index];
              return AvCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textMain)),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot['sources']} Sources -> ${snapshot['destinations']} Destinations',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Recalled snapshot: ${snapshot['title']}')),
                            );
                          },
                          child: const Text('Recall', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 18, color: AppTheme.textMuted),
                        ),
                      ],
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
