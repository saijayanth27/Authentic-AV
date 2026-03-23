import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../models/device_model.dart';
import '../logic/app_state.dart';

class PreviewsModule extends StatefulWidget {
  const PreviewsModule({super.key});

  @override
  State<PreviewsModule> createState() => _PreviewsModuleState();
}

class _PreviewsModuleState extends State<PreviewsModule> {
  final Map<String, VideoPlayerController> _destControllers = {};

  List<Device> get _allDestinations =>
      AppState.instance.destinationsByLocation.values.expand((d) => d).toList();
  List<Device> get _sources => AppState.instance.sources;
  Map<String, String?> get _activeRoutes => AppState.instance.activeRoutes;

  @override
  void initState() {
    super.initState();
    AppState.instance.initializeSampleData();

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
        const Text(
          'Live Previews',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Real-time video feed of all destination displays.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 320,
            crossAxisSpacing: isMobile ? 12 : 16,
            mainAxisSpacing: isMobile ? 12 : 16,
            mainAxisExtent: 210,
          ),
          itemCount: _allDestinations.length,
          itemBuilder: (ctx, i) {
            final dest = _allDestinations[i];
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
          },
        ),
      ],
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
