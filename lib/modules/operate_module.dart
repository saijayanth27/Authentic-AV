import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../models/device_model.dart';
import '../logic/app_state.dart';

enum ViewMode { largeGrid, compactGrid, list }

class OperateModule extends StatefulWidget {
  const OperateModule({super.key});

  @override
  State<OperateModule> createState() => _OperateModuleState();
}

class _OperateModuleState extends State<OperateModule> {
  ViewMode _viewMode = ViewMode.largeGrid;

  Map<String, String?> get _activeRoutes => AppState.instance.activeRoutes;
  List<Device> get _sources => AppState.instance.sources;
  Map<String, List<Device>> get _destinationsByLocation => AppState.instance.destinationsByLocation;

  final Map<String, VideoPlayerController> _destControllers = {};
  final Map<String, VideoPlayerController> _sourcePreviewControllers = {};
  final Map<String, bool> _expandedLocations = {};

  List<Device> get _allDestinations =>
      _destinationsByLocation.values.expand((d) => d).toList();

  @override
  void initState() {
    super.initState();
    AppState.instance.initializeSampleData();

    for (final loc in _destinationsByLocation.keys) {
      _expandedLocations[loc] = true;
    }

    // Initialize source preview controllers for the bottom sheet
    for (final s in _sources) {
      if (s.videoUrl != null) {
        final ctrl = VideoPlayerController.asset(s.videoUrl!);
        _sourcePreviewControllers[s.id] = ctrl;
        ctrl.initialize().then((_) {
          if (mounted) setState(() {});
          ctrl.setLooping(true);
          ctrl.setVolume(0);
          ctrl.play();
        }).catchError((e) { debugPrint('Preview video error: $e'); return null; });
      }
    }

    // Restore existing destination videos if they are routed
    _syncDestControllers();
    AppState.instance.stateVersionNotifier.addListener(_syncDestControllers);
  }

  void _syncDestControllers() {
    for (final dest in _allDestinations) {
      final routeId = _activeRoutes[dest.id];
      if (routeId != null) {
        final source = _sources.firstWhere((s) => s.id == routeId, orElse: () => _sources.first);
        if (source.videoUrl != null && _destControllers[dest.id] == null) {
          final ctrl = VideoPlayerController.asset(source.videoUrl!);
          _destControllers[dest.id] = ctrl;
          ctrl.initialize().then((_) {
            if (mounted) setState(() {});
            ctrl.setLooping(true);
            ctrl.setVolume(0);
            ctrl.play();
          });
        }
      } else {
        _destControllers[dest.id]?.dispose();
        _destControllers.remove(dest.id);
      }
    }
  }

  @override
  void dispose() {
    AppState.instance.stateVersionNotifier.removeListener(_syncDestControllers);
    for (var ctrl in _destControllers.values) {
      ctrl.dispose();
    }
    for (var ctrl in _sourcePreviewControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _changeRoute(String destId, String sourceId) {
    setState(() {
      _activeRoutes[destId] = sourceId;
      
      final source = _sources.firstWhere((s) => s.id == sourceId);
      if (source.videoUrl != null) {
        _destControllers[destId]?.dispose();
        final ctrl = VideoPlayerController.asset(source.videoUrl!);
        _destControllers[destId] = ctrl;
        ctrl.initialize().then((_) {
          if (mounted) setState(() {});
          ctrl.setLooping(true);
          ctrl.setVolume(0);
          ctrl.play();
        }).catchError((e) { debugPrint('Video error: $e'); return null; });
      } else {
        _destControllers[destId]?.dispose();
        _destControllers.remove(destId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.black, size: 20),
            const SizedBox(width: 10),
            Text('Matrix command executed instantly.', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.greenAccent.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.instance.stateVersionNotifier,
      builder: (context, _, child) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        return Column(
          children: [
            _buildControlHeader(isMobile),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _destinationsByLocation.entries.map((entry) {
                    return _buildLocationGroup(entry.key, entry.value, isMobile);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(bottom: BorderSide(color: Colors.grey.shade900)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Displays',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.highlightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _viewModeCapsule(ViewMode.largeGrid, Icons.grid_view_rounded),
                Container(width: 1, height: 16, color: Colors.grey.shade800),
                _viewModeCapsule(ViewMode.compactGrid, Icons.grid_on_rounded),
                Container(width: 1, height: 16, color: Colors.grey.shade800),
                _viewModeCapsule(ViewMode.list, Icons.view_list_rounded),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isMobile 
            ? InkWell(
                onTap: _showAddDestinationDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              )
            : ElevatedButton.icon(
                onPressed: _showAddDestinationDialog,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add Display', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentWhite,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
        ],
      ),
    );
  }

  Widget _viewModeCapsule(ViewMode mode, IconData icon) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade800 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? AppTheme.accentWhite : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildLocationGroup(String location, List<Device> devices, bool isMobile) {
    final isExpanded = _expandedLocations[location] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.highlightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expandedLocations[location] = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    location,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${devices.length} display${devices.length == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _viewMode != ViewMode.list
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: _viewMode == ViewMode.largeGrid ? 260 : 160,
                        crossAxisSpacing: isMobile ? 12 : 16,
                        mainAxisSpacing: isMobile ? 12 : 16,
                        mainAxisExtent: _viewMode == ViewMode.largeGrid ? 200 : 150,
                      ),
                      itemCount: devices.length,
                      itemBuilder: (ctx, i) => _buildGridCard(devices[i]),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devices.length,
                      itemBuilder: (ctx, i) => _buildListCard(devices[i]),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridCard(Device dest) {
    final activeSourceId = _activeRoutes[dest.id];
    final activeSource = activeSourceId != null ? 
        _sources.cast<Device?>().firstWhere((s) => s?.id == activeSourceId, orElse: () => null) : null;

    return GestureDetector(
      onTap: () => _showSourceSelectionSheet(dest),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              Expanded(
                child: _buildVideoPreview(dest, activeSource),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dest.name,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.cast_connected, size: 10, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  activeSource?.name ?? 'No Source Selected',
                                  style: TextStyle(
                                    color: activeSource != null ? Colors.greenAccent : Colors.grey.shade600, 
                                    fontSize: 11, 
                                    fontWeight: activeSource != null ? FontWeight.bold : FontWeight.normal
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showSourceSelectionSheet(dest),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.highlightGrey,
                        foregroundColor: AppTheme.accentWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Change', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(Device dest) {
    final activeSourceId = _activeRoutes[dest.id];
    final activeSource = activeSourceId != null ? 
        _sources.cast<Device?>().firstWhere((s) => s?.id == activeSourceId, orElse: () => null) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: _buildVideoPreview(dest, activeSource, showOverlay: false),
          ),
        ),
        title: Text(
          dest.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.cast_connected, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              activeSource?.name ?? 'No Source',
              style: TextStyle(
                color: activeSource != null ? Colors.greenAccent : Colors.grey.shade600,
                fontSize: 12,fontWeight: activeSource != null ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _showSourceSelectionSheet(dest),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.highlightGrey,
            foregroundColor: AppTheme.accentWhite,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Select Source', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(Device dest, Device? routedSource, {bool showOverlay = true}) {
    if (routedSource != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          (_destControllers[dest.id] != null && _destControllers[dest.id]!.value.isInitialized)
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _destControllers[dest.id]!.value.size.width,
                    height: _destControllers[dest.id]!.value.size.height,
                    child: VideoPlayer(_destControllers[dest.id]!),
                  ),
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: (_destControllers[dest.id] != null && _destControllers[dest.id]!.value.hasError)
                        ? Icon(Icons.broken_image_outlined, color: Colors.grey.shade800, size: 32)
                        : const CircularProgressIndicator(color: AppTheme.accentWhite, strokeWidth: 2),
                  ),
                ),
          if (showOverlay)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_outlined, size: 24, color: Colors.grey.shade700),
            if (showOverlay) ...[
              const SizedBox(height: 4),
              Text(
                'NO SIGNAL',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Source Selection Bottom Sheet ─────────────────────────────────────────

  void _showSourceSelectionSheet(Device destination) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade900)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentWhite)),
                        Text('Routing to ${destination.name}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 140,
                    ),
                    itemCount: _sources.length,
                    itemBuilder: (context, i) {
                      final src = _sources[i];
                      return _buildSourceOptionCard(src, destination, ctx);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOptionCard(Device source, Device destination, BuildContext modalContext) {
    final isSelected = _activeRoutes[destination.id] == source.id;
    
    return GestureDetector(
      onTap: () {
        _changeRoute(destination.id, source.id);
        Navigator.pop(modalContext);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppTheme.highlightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.grey.shade800,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              (_sourcePreviewControllers[source.id] != null && _sourcePreviewControllers[source.id]!.value.isInitialized)
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _sourcePreviewControllers[source.id]!.value.size.width,
                        height: _sourcePreviewControllers[source.id]!.value.size.height,
                        child: VideoPlayer(_sourcePreviewControllers[source.id]!),
                      ),
                    )
                  : Container(color: Colors.black54),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSelected) 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(4)),
                        child: const Text('ACTIVE', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    const Spacer(),
                    Text(
                      source.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      source.location,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Provisioning Dialogs ──────────────────────────────────────────────────

  void _showAddDestinationDialog() {
    final nameCtrl = TextEditingController();
    final ipCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundLight,
        title: const Text('Provision Display', style: TextStyle(color: AppTheme.accentWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Display Name', labelStyle: TextStyle(color: Colors.grey))),
            TextField(controller: ipCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'IP Address', labelStyle: TextStyle(color: Colors.grey))),
            TextField(controller: locCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Location Group', labelStyle: TextStyle(color: Colors.grey))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentWhite, foregroundColor: Colors.black),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && locCtrl.text.isNotEmpty) {
                final loc = locCtrl.text;
                final newDevice = Device(
                  id: 'dest_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  ip: ipCtrl.text,
                  type: DeviceType.rx,
                  status: DeviceStatus.online,
                  location: loc,
                );
                
                if (!AppState.instance.destinationsByLocation.containsKey(loc)) {
                  AppState.instance.destinationsByLocation[loc] = [];
                  _expandedLocations[loc] = true;
                }
                AppState.instance.destinationsByLocation[loc]!.add(newDevice);
                AppState.instance.notifyListeners();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Provision'),
          ),
        ],
      ),
    );
  }
}
