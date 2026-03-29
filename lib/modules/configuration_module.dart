import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../logic/app_state.dart';
import '../models/device_model.dart';

class ConfigurationModule extends StatefulWidget {
  const ConfigurationModule({super.key});

  @override
  State<ConfigurationModule> createState() => _ConfigurationModuleState();
}

class _ConfigurationModuleState extends State<ConfigurationModule> {
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
        content: Column(
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
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  // Deletion phase
                  if (device.type == DeviceType.tx) {
                    AppState.instance.sources.removeWhere((s) => s.id == device.id);
                    AppState.instance.activeRoutes.removeWhere((key, val) => val == device.id);
                  } else {
                    for (var key in AppState.instance.destinationsByLocation.keys) {
                      AppState.instance.destinationsByLocation[key]!.removeWhere((d) => d.id == device.id);
                    }
                    AppState.instance.activeRoutes.remove(device.id);
                  }
                  AppState.instance.notifyListeners();
                  Navigator.pop(ctx);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${device.name} Decoupled'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Text('DECOMMISSION', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentWhite, 
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () {
                  device.name = nameCtrl.text.isNotEmpty ? nameCtrl.text : device.name;
                  device.ip = ipCtrl.text.isNotEmpty ? ipCtrl.text : device.ip;
                  device.location = locCtrl.text.isNotEmpty ? locCtrl.text : device.location;
                  
                  AppState.instance.notifyListeners();
                  Navigator.pop(ctx);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${device.name} Configured'), backgroundColor: Colors.greenAccent, behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.highlightGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isOnline ? Colors.white.withValues(alpha: 0.1) : Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
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
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      dev.name, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.accentWhite),
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isTx ? Colors.purpleAccent.withValues(alpha: 0.15) : Colors.blueAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isTx ? 'TX' : 'RX', 
                                      style: TextStyle(
                                        color: isTx ? Colors.purpleAccent : Colors.blueAccent, 
                                        fontSize: 10, 
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      )
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.lan_outlined, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Text(
                                    dev.ip, 
                                    style: TextStyle(
                                      color: Colors.grey.shade400, 
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isOnline ? 'ONLINE' : 'OFFLINE',
                                    style: TextStyle(
                                      color: isOnline ? Colors.greenAccent.withValues(alpha: 0.7) : Colors.redAccent.withValues(alpha: 0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showEditDeviceDialog(dev),
                          icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 22),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                            padding: const EdgeInsets.all(8),
                          ),
                          tooltip: 'Hardware Parameters',
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
}
