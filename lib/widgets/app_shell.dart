import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../modules/operate_module.dart';
import '../modules/discovery_module.dart';
import '../modules/configuration_module.dart';
import '../modules/troubleshooting_module.dart';
import '../modules/snapshots_module.dart';
import '../modules/help_module.dart';
import '../modules/ai_assistant_module.dart';
import '../modules/tests_module.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _isAdminMode = true;

  final List<Map<String, dynamic>> _allNavItems = [
    {'icon': Icons.settings_input_component, 'label': 'Operate', 'module': const OperateModule()},
    {'icon': Icons.search, 'label': 'Discovery', 'adminOnly': true, 'module': const DiscoveryModule()},
    {'icon': Icons.settings, 'label': 'Configuration', 'adminOnly': true, 'module': const ConfigurationModule()},
    {'icon': Icons.build, 'label': 'Troubleshooting', 'adminOnly': true, 'module': const TroubleshootingModule()},
    {'icon': Icons.camera_alt, 'label': 'Snapshots', 'module': const SnapshotsModule()},
    {'icon': Icons.help_outline, 'label': 'Help', 'module': const HelpModule()},
    {'icon': Icons.auto_awesome, 'label': 'AI Assistant', 'module': const AiAssistantModule()},
    {'icon': Icons.checklist, 'label': 'Tests', 'adminOnly': true, 'module': const TestsModule()},
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> visibleItems = _isAdminMode
        ? _allNavItems
        : _allNavItems.where((item) => item['adminOnly'] != true).toList();

    // Ensure _selectedIndex is within bounds when admin mode changes
    if (_selectedIndex >= visibleItems.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'A',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AuthenticAV',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'AVoIP Control System',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAdminMode ? Icons.admin_panel_settings : Icons.person,
                color: AppTheme.primaryPurple,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                _isAdminMode ? 'Admin' : 'User',
                style: const TextStyle(
                  color: AppTheme.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _isAdminMode,
                  onChanged: (val) => setState(() => _isAdminMode = val),
                  activeColor: AppTheme.primaryPurple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.primaryPurple),
              child: const Center(
                child: Text(
                  'AuthenticAV',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ...List.generate(visibleItems.length, (index) {
              final item = visibleItems[index];
              return ListTile(
                leading: Icon(
                  item['icon'] as IconData,
                  color: _selectedIndex == index ? AppTheme.primaryPurple : Colors.black54,
                ),
                title: Text(item['label'] as String),
                selected: _selectedIndex == index,
                selectedTileColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
      body: visibleItems[_selectedIndex]['module'] as Widget,
    );
  }
}
