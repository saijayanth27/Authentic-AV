import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../logic/app_state.dart';
import '../models/device_model.dart';
import '../services/database_service.dart';

class ConfigurationModule extends StatefulWidget {
  const ConfigurationModule({super.key});

  @override
  State<ConfigurationModule> createState() => _ConfigurationModuleState();
}

class _ConfigurationModuleState extends State<ConfigurationModule> {
  @override
  void initState() {
    super.initState();
    // Use postFrameCallback to ensure the dialog triggers AFTER the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNewAdoption();
    });
    // Listen for tab changes as well (Configuration is index 3)
    AppState.instance.tabIndexNotifier.addListener(_checkNewAdoption);
  }

  @override
  void dispose() {
    AppState.instance.tabIndexNotifier.removeListener(_checkNewAdoption);
    super.dispose();
  }

  void _checkNewAdoption() {
    // Only proceed if the configuration tab is now active (index 3)
    if (AppState.instance.tabIndexNotifier.value != 3) return;

    final newId = AppState.instance.lastAdoptedDeviceId;
    if (newId != null) {
      // Use postFrame to ensure any existing build cycle is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final device = _allDevices.firstWhere((d) => d.id == newId);
          _showEditDeviceDialog(device);
        } catch (e) {
          debugPrint('Auto-focus failed: Device $newId not found in registry');
        }
        AppState.instance.lastAdoptedDeviceId = null;
      });
    }
  }

  // Deep extraction of global devices
  List<Device> get _allDevices {
    final List<Device> all = [];
    all.addAll(AppState.instance.sources);
    for (var list in AppState.instance.destinationsByLocation.values) {
      all.addAll(list);
    }
    // Sort generically
    all.sort((a, b) => a.name.compareTo(b.name));
    return all;
  }

  void _showEditDeviceDialog(Device device) {
    final nameCtrl = TextEditingController(text: device.name);
    final ipCtrl = TextEditingController(text: device.ip);
    final locCtrl = TextEditingController(text: device.location);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              device.type == DeviceType.tx ? Icons.settings_input_hdmi : Icons.monitor,
              color: AppTheme.accentWhite,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Hardware Configuration', 
              style: const TextStyle(color: AppTheme.accentWhite, fontSize: 20, fontWeight: FontWeight.bold)
            ),
            Text(
              'Modify parameters for ${device.name}',
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.white12, height: 24),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Alias Name', 
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.abc, color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ipCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'monospace'),
              decoration: InputDecoration(
                labelText: 'Static IP Address', 
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.lan_outlined, color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Deployment Zone',
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.place_outlined, color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (device.type == DeviceType.rx)
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('OSD Triggered on ${device.name}: Displaying Identity Overlay'),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                    tooltip: 'Show Info on Screen',
                  ),
                IconButton(
                  onPressed: () => AppState.instance.toggleWink(device.id),
                  icon: Icon(
                    device.isWinking ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded, 
                    color: device.isWinking ? Colors.yellowAccent : Colors.white70
                  ),
                  tooltip: 'ID / Wink Device',
                ),
                TextButton(
                  onPressed: () async {
                    await AppState.instance.removeDevice(device.id, device.location);
                    if (device.type == DeviceType.tx) {
                      AppState.instance.activeRoutes.removeWhere((key, val) => val == device.id);
                    } else {
                      AppState.instance.activeRoutes.remove(device.id);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${device.name} Decoupled'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: const Text('DECOMMISSION', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentWhite, 
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final oldLocation = device.location;
                    final newName = nameCtrl.text.isNotEmpty ? nameCtrl.text : device.name;
                    final newIp = ipCtrl.text.isNotEmpty ? ipCtrl.text : device.ip;
                    final newLocation = locCtrl.text.isNotEmpty ? locCtrl.text : device.location;

                    device.name = newName;
                    device.ip = newIp;

                    // If location changed, move device to new location group
                    if (newLocation != oldLocation && device.type != DeviceType.tx) {
                      AppState.instance.destinationsByLocation[oldLocation]?.remove(device);
                      if (AppState.instance.destinationsByLocation[oldLocation]?.isEmpty ?? false) {
                        AppState.instance.destinationsByLocation.remove(oldLocation);
                      }
                      AppState.instance.destinationsByLocation.putIfAbsent(newLocation, () => []);
                      AppState.instance.destinationsByLocation[newLocation]!.add(device);
                    }
                    device.location = newLocation;

                    // Persist to DB
                    await DatabaseService.instance.saveAdoptedDevice(device);
                    if (ctx.mounted) {
                      AppState.instance.notifyListeners();
                      Navigator.pop(ctx);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${device.name} Configured'), backgroundColor: Colors.greenAccent, behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.instance.stateVersionNotifier,
      builder: (context, _, child) {
        // PROACTIVE ADOPTION CHECK:
        // Every time the global state changes, check if we need to show the naming menu.
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkNewAdoption());

        final devices = _allDevices;
        final isMobile = MediaQuery.of(context).size.width < 700;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Device Configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              const SizedBox(height: 4),
              const Text('Manage device settings, IDs, and infrastructure deployments locally.', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500,
                  crossAxisSpacing: isMobile ? 12.0 : 20.0,
                  mainAxisSpacing: isMobile ? 12.0 : 20.0,
                  mainAxisExtent: 110, // Increased for status bar
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final dev = devices[index];
                  final isTx = dev.type == DeviceType.tx;
                  final isOnline = dev.status == DeviceStatus.online;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.highlightGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isOnline ? Colors.white.withValues(alpha: 0.1) : Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _buildPulsatingIcon(dev),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            dev.name, 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentWhite),
                                            maxLines: 1, 
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isTx ? Colors.purpleAccent.withValues(alpha: 0.15) : Colors.blueAccent.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: (isTx ? Colors.purpleAccent : Colors.blueAccent).withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            isTx ? 'TX' : 'RX', 
                                            style: TextStyle(
                                              color: isTx ? Colors.purpleAccent : Colors.blueAccent, 
                                              fontSize: 9, 
                                              fontWeight: FontWeight.bold,
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.lan_outlined, size: 12, color: Colors.grey.shade500),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            dev.ip, 
                                            style: TextStyle(
                                              color: Colors.grey.shade500, 
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick Actions Overlay (Anchored to top right for responsiveness)
                        Positioned(
                          top: 8, right: 8,
                          child: Row(
                            children: [
                              if (dev.type == DeviceType.rx)
                                _miniActionButton(
                                  icon: Icons.personal_video_rounded,
                                  color: Colors.cyanAccent,
                                  tooltip: 'Trigger OSD (JPEG Overlay)',
                                  onTap: () {
                                    _showOSDOverlay(dev);
                                  },
                                ),
                              const SizedBox(width: 6),
                              _miniActionButton(
                                icon: dev.isWinking ? Icons.light_mode_rounded : Icons.light_mode_outlined, 
                                color: dev.isWinking ? Colors.orangeAccent : Colors.white60,
                                active: dev.isWinking,
                                tooltip: 'Identify / Wink LED',
                                onTap: () => AppState.instance.toggleWink(dev.id),
                              ),
                              const SizedBox(width: 6),
                              _miniActionButton(
                                icon: Icons.tune_rounded,
                                color: Colors.white70,
                                tooltip: 'Configure',
                                onTap: () => _showEditDeviceDialog(dev),
                              ),
                            ],
                          ),
                        ),
                        // Status Indicator Tag at bottom right
                        Positioned(
                          bottom: 12, right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isOnline ? Colors.green : Colors.red).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOnline ? 'ONLINE' : 'OFFLINE',
                              style: TextStyle(
                                color: isOnline ? Colors.greenAccent : Colors.redAccent,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildPulsatingIcon(Device dev) {
    final isTx = dev.type == DeviceType.tx;
    final isOnline = dev.status == DeviceStatus.online;

    return Stack(
      children: [
        if (dev.isWinking)
          TweenAnimationBuilder<double>(
            key: ValueKey('wink_${dev.id}_${DateTime.now().millisecondsSinceEpoch ~/ 1000}'), // Force loop
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              final opacity = (0.5 - (value - 0.5).abs()) * 2; // Pulse up and down
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withValues(alpha: 0.6 * opacity),
                      blurRadius: 15 * opacity,
                      spreadRadius: 8 * opacity,
                    ),
                  ],
                ),
              );
            },
          ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dev.isWinking ? Colors.orangeAccent : Colors.white10,
              width: dev.isWinking ? 2 : 1,
            ),
          ),
          child: Center(
            child: (dev.previewUrl != null && dev.previewUrl!.isNotEmpty)
                ? Image.asset(
                    'assets/images/${dev.previewUrl!}',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      isTx ? Icons.settings_input_hdmi : Icons.monitor,
                      color: isTx ? Colors.purpleAccent : Colors.blueAccent,
                      size: 24,
                    ),
                  )
                : Icon(
                    isTx ? Icons.settings_input_hdmi : Icons.monitor,
                    color: isTx ? Colors.purpleAccent : Colors.blueAccent,
                    size: 24,
                  ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isOnline ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.highlightGrey, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniActionButton({required IconData icon, required Color color, required VoidCallback onTap, bool active = false, String? tooltip}) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: active ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: active ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, size: 14, color: active ? color : Colors.white70),
          ),
        ),
      ),
    );
  }

  void _showOSDOverlay(Device device) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(230),
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 500,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent, width: 3),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/auth.av_icon_v2.png'),
                      opacity: 0.1,
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monitor_rounded, color: Colors.cyanAccent, size: 64),
                      const SizedBox(height: 20),
                      Text(
                        device.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          device.ip,
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'OSD IDENTIFICATION ACTIVE',
                        style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 32),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
