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
    List<Map<String, dynamic>> visibleItems = _isAdminMode 
        ? _allNavItems 
        : _allNavItems.where((item) => item['adminOnly'] != true).toList();

    // Ensure _selectedIndex is within bounds if isAdminMode changes
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
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'A',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Authentic AV', 
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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _isAdminMode ? 'ADMIN' : 'USER',
                      style: const TextStyle(
                        color: AppTheme.primaryTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 24,
                    width: 32,
                    child: Switch(
                      value: _isAdminMode,
                      onChanged: (val) => setState(() => _isAdminMode = val),
                      activeColor: AppTheme.primaryTeal,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                var item = visibleItems[index];
                return InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'], size: 20, color: isSelected ? AppTheme.primaryTeal : Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          item['label'],
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryTeal : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: visibleItems[_selectedIndex]['module'],
          ),
        ],
      ),
    );
  }
}
