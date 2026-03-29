import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../modules/operate_module.dart';
import '../modules/previews_module.dart';
import '../modules/discovery_module.dart';
import '../modules/configuration_module.dart';
import '../modules/troubleshooting_module.dart';
import '../modules/snapshots_module.dart';
import '../modules/help_module.dart';
import '../modules/tests_module.dart';
import '../modules/users_module.dart';
import '../screens/login_screen.dart';

class AppShell extends StatefulWidget {
  final bool isAdmin;
  const AppShell({super.key, required this.isAdmin});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _allNavItems = [
    {'icon': Icons.grid_view_rounded, 'label': 'Live Previews', 'module': const PreviewsModule()},
    {'icon': Icons.settings_input_component_outlined, 'label': 'Operate', 'module': const OperateModule()},
    {'icon': Icons.manage_search_outlined, 'label': 'Discovery', 'adminOnly': true, 'module': const DiscoveryModule()},
    {'icon': Icons.settings_outlined, 'label': 'Configuration', 'adminOnly': true, 'module': const ConfigurationModule()},
    {'icon': Icons.admin_panel_settings_outlined, 'label': 'Access Control', 'adminOnly': true, 'module': const UsersModule()},
    {'icon': Icons.build_outlined, 'label': 'Troubleshooting', 'adminOnly': true, 'module': const TroubleshootingModule()},
    {'icon': Icons.camera_alt_outlined, 'label': 'Snapshots', 'module': const SnapshotsModule()},
    {'icon': Icons.help_outline, 'label': 'Help', 'module': const HelpModule()},
    {'icon': Icons.checklist_rtl_outlined, 'label': 'Tests', 'adminOnly': true, 'module': const TestsModule()},
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> visibleItems = widget.isAdmin
        ? _allNavItems
        : _allNavItems.where((item) => item['adminOnly'] != true).toList();

    // Ensure _selectedIndex is within bounds when admin mode changes
    if (_selectedIndex >= visibleItems.length) {
      _selectedIndex = 0;
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        toolbarHeight: isMobile ? 60 : 70,
        backgroundColor: AppTheme.backgroundLight, // Sleek Pitch Black Apple TV Header
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Authentic AV',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'New York'),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      visibleItems[_selectedIndex]['label'],
                      style: TextStyle(fontSize: 16, color: AppTheme.accentWhite.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                widget.isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                color: AppTheme.accentWhite,
                size: 18,
              ),
              if (!isMobile) ...[
                const SizedBox(width: 6),
                Text(
                  widget.isAdmin ? 'Admin' : 'User',
                  style: const TextStyle(
                    color: AppTheme.accentWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: AppTheme.accentWhite, size: 20),
                tooltip: 'Logout',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ), // closes AppBar
      drawer: Drawer(
        backgroundColor: AppTheme.backgroundLight,
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade800, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Image(
                        image: AssetImage('assets/images/auth.av_purple-white.png'),
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Authentic AV',
                      style: TextStyle(
                        color: AppTheme.accentWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'New York',
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EXPERIENCE CONTROL',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.grey.shade900, height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: visibleItems.length,
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  final isSelected = _selectedIndex == index;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    dense: true,
                    leading: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isSelected ? AppTheme.accentWhite : AppTheme.textMuted,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppTheme.accentWhite : AppTheme.textMuted,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppTheme.highlightGrey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    style: ListTileStyle.drawer,
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: visibleItems.map((item) => item['module'] as Widget).toList(),
      ),
    );
  }
}
