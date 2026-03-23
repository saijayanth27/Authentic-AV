import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        title: Text('Edit ${device.type == DeviceType.tx ? 'Source' : 'Destination'}', style: const TextStyle(color: AppTheme.accentWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(labelText: 'Device Name', labelStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ipCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(labelText: 'IP Address', labelStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(labelText: 'Deployment Location', labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              // Deletion phase
              if (device.type == DeviceType.tx) {
                AppState.instance.sources.removeWhere((s) => s.id == device.id);
                // Sever any active routes pointing to this source
                AppState.instance.activeRoutes.removeWhere((key, val) => val == device.id);
              } else {
                for (var key in AppState.instance.destinationsByLocation.keys) {
                  AppState.instance.destinationsByLocation[key]!.removeWhere((d) => d.id == device.id);
                }
                // Sever any active routes attached to this destination
                AppState.instance.activeRoutes.remove(device.id);
              }
              AppState.instance.notifyListeners();
              Navigator.pop(ctx);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${device.name} Terminated'), backgroundColor: Colors.redAccent.shade400, behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentWhite, foregroundColor: Colors.black),
            onPressed: () {
              // Apply mutations
              device.name = nameCtrl.text.isNotEmpty ? nameCtrl.text : device.name;
              device.ip = ipCtrl.text.isNotEmpty ? ipCtrl.text : device.ip;
              device.location = locCtrl.text.isNotEmpty ? locCtrl.text : device.location;
              
              AppState.instance.notifyListeners();
              Navigator.pop(ctx);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${device.name} Updated'), backgroundColor: Colors.greenAccent.shade400, behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Save Config'),
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
                  maxCrossAxisExtent: 400,
                  crossAxisSpacing: isMobile ? 12.0 : 20.0,
                  mainAxisSpacing: isMobile ? 12.0 : 20.0,
                  mainAxisExtent: 90, // Strict dashboard density
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final dev = devices[index];
                  final isTx = dev.type == DeviceType.tx;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.highlightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: Center(
                            child: dev.previewUrl != null
                                ? Image.asset(
                                    'assets/logos/${dev.previewUrl}',
                                    width: 20,
                                    height: 20,
                                  )
                                : Icon(
                                    isTx ? Icons.router_outlined : Icons.tv_outlined,
                                    color: isTx ? Colors.purpleAccent : Colors.blueAccent,
                                    size: 20,
                                  ),
                          ),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentWhite),
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isTx ? Colors.purpleAccent.withValues(alpha: 0.1) : Colors.blueAccent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(isTx ? 'TX' : 'RX', style: TextStyle(color: isTx ? Colors.purpleAccent : Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.hub_outlined, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(dev.ip, style: TextStyle(color: Colors.grey.shade400, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _showEditDeviceDialog(dev),
                          icon: const Icon(Icons.edit_note_rounded, color: AppTheme.accentWhite, size: 24),
                          tooltip: 'Configure Hardware',
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
