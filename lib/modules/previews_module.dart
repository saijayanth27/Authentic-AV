import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../models/device_model.dart';
import '../logic/app_state.dart';
import 'operate_module.dart' show ViewMode;

class PreviewsModule extends StatefulWidget {
  const PreviewsModule({super.key});

  @override
  State<PreviewsModule> createState() => _PreviewsModuleState();
}

class _PreviewsModuleState extends State<PreviewsModule> {
  final Map<String, VideoPlayerController> _destControllers = {};

  final Map<String, bool> _expandedLocations = {};
  ViewMode _viewMode = ViewMode.largeGrid;

  List<Device> get _allDestinations =>
      AppState.instance.destinationsByLocation.values.expand((d) => d).toList();
  Map<String, List<Device>> get _destinationsByLocation =>
      AppState.instance.destinationsByLocation;
  List<Device> get _sources => AppState.instance.sources;
  Map<String, String?> get _activeRoutes => AppState.instance.activeRoutes;

  @override
  void initState() {
    super.initState();
    AppState.instance.initializeSampleData();
    for (final loc in _destinationsByLocation.keys) {
      _expandedLocations[loc] = true;
    }

    // Setup active routes if none exist to show live video on previews
    if (AppState.instance.activeRoutes.isEmpty) {
      final dests = _allDestinations;
      for (int i = 0; i < dests.length; i++) {
        if (i < _sources.length) {
          AppState.instance.activeRoutes[dests[i].id] = _sources[i].id;
        }
      }
    }

    _syncControllers();
    AppState.instance.stateVersionNotifier.addListener(_syncControllers);
  }

  void _syncControllers() {
    for (final dest in _allDestinations) {
      final routeId = _activeRoutes[dest.id];
      if (routeId != null) {
        final source = _sources.firstWhere((s) => s.id == routeId, orElse: () => _sources.first);
        if (source.videoUrl != null) {
          if (_destControllers[dest.id] == null) {
            final url = source.videoUrl!;
            final ctrl = url.startsWith('http')
                ? VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
                : VideoPlayerController.asset(url, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
            _destControllers[dest.id] = ctrl;
            ctrl.initialize().then((_) {
              if (mounted) setState(() {});
              ctrl.setLooping(true);
              ctrl.setVolume(0);
              ctrl.play();
            });
          } else {
            // Already exists, just ensure it's still playing
            final ctrl = _destControllers[dest.id]!;
            if (ctrl.value.isInitialized && !ctrl.value.isPlaying) {
              try {
                ctrl.play();
              } catch (_) {}
            }
          }
        }
      } else {
        _destControllers[dest.id]?.dispose();
        _destControllers.remove(dest.id);
      }
    }
  }

  @override
  void dispose() {
    AppState.instance.stateVersionNotifier.removeListener(_syncControllers);
    for (var ctrl in _destControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.instance.stateVersionNotifier,
      builder: (context, _, child) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: _buildDestinationPreviews(isMobile),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDestinationPreviews(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildControlHeader(isMobile),
        const SizedBox(height: 20),
        ..._destinationsByLocation.entries.map((entry) {
          return _buildLocationGroup(entry.key, entry.value, isMobile);
        }).toList(),
      ],
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
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
                        maxCrossAxisExtent: _viewMode == ViewMode.largeGrid ? 320 : 160,
                        crossAxisSpacing: isMobile ? 12 : 16,
                        mainAxisSpacing: isMobile ? 12 : 16,
                        mainAxisExtent: _viewMode == ViewMode.largeGrid ? 210 : 180,
                      ),
                      itemCount: devices.length,
                      itemBuilder: (ctx, i) {
                        return _buildGridCard(devices[i]);
                      },
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
              'Live Previews',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade800 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildListCard(Device dest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMonitorContent(dest),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dest.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade900.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'LIVE',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        dest.location,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(Device dest) {
    return Container(
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
              child: _buildMonitorContent(dest),
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
                        Text(
                          dest.location,
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade900.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitorContent(Device dest) {
    final routedSourceId = _activeRoutes[dest.id];
    final routedSource = routedSourceId != null ? _sources.firstWhere((s) => s.id == routedSourceId, orElse: () => _sources.first) : null;

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
                  child: const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentWhite),
                  ),
                ),
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
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cast_connected, size: 12, color: AppTheme.accentWhite),
                  const SizedBox(width: 6),
                  Text(
                    routedSource.name,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
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
            Icon(Icons.monitor_outlined, size: 40, color: Colors.grey.shade700),
            const SizedBox(height: 8),
            Text(
              'NO SIGNAL',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
