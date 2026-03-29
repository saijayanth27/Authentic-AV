import 'package:flutter/foundation.dart';
import '../models/device_model.dart';

class UserAccount {
  final String id;
  final String username;
  final String password;
  final String role;

  UserAccount({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });
}

class AppState extends ChangeNotifier {
  // Singleton instance
  static final AppState instance = AppState._internal();
  AppState._internal() {
    initializeSampleData();
  }

  // Active Device Registries
  final List<Device> sources = [];
  final Map<String, List<Device>> destinationsByLocation = {};
  
  // Security/RBAC Authentication Registry
  final List<UserAccount> users = [];

  // Active Matrix Routing Paths (Destination ID -> Source ID)
  final Map<String, String?> activeRoutes = {};

  // Saved routing configurations
  final List<Map<String, dynamic>> savedSnapshots = [];

  // Global Notifiers for listeners (Snapshots, Operate)
  final ValueNotifier<int> stateVersionNotifier = ValueNotifier<int>(0);

  // Initialize with the standard dummy data if empty
  void initializeSampleData() {
    if (sources.isNotEmpty) return;

    // Standard Sample Sources
    sources.addAll([
      Device(
        id: 's1',
        name: 'Netflix Box',
        ip: '192.168.1.101',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'AV Rack 1',
        tags: ['Movies', 'Streaming'],
        videoUrl: 'assets/videos/demo_video_1.mp4',
        previewUrl: 'netflix.png',
      ),
      Device(
        id: 's2',
        name: 'YouTube TV',
        ip: '192.168.1.102',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'AV Rack 1',
        tags: ['Live Stream', 'Streaming'],
        videoUrl: 'assets/videos/demo_video_2.mp4',
        previewUrl: 'youtube.png',
      ),
      Device(
        id: 's3',
        name: 'Hulu Live TV',
        ip: '192.168.1.103',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'Breakroom AV',
        tags: ['Live TV', 'Streaming'],
        videoUrl: 'assets/videos/demo_video_3.mp4',
        previewUrl: 'hdmi.png',
      ),
      Device(
        id: 's4',
        name: 'Twitch Studio',
        ip: '192.168.1.104',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'Server Room',
        tags: ['Gaming', 'Live Stream'],
        videoUrl: 'assets/videos/demo_video_4.mp4',
        previewUrl: 'auth.av_icon_v2.png',
      ),
      Device(
        id: 's5',
        name: 'Disney+ Stream',
        ip: '192.168.1.105',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'Theater Room',
        videoUrl: 'assets/videos/demo_video_5.mp4',
        tags: ['Movies', 'Streaming'],
        previewUrl: 'auth.av_icon_v2.png',
      ),
      Device(
        id: 's6',
        name: 'Apple TV 4K',
        ip: '192.168.1.106',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'AV Rack 2',
        videoUrl: 'assets/videos/demo_video_6.mp4',
        tags: ['Movies', 'Streaming'],
        previewUrl: 'appletv.png',
      ),
    ]);
    
    // Inject Mock Security Database
    users.addAll([
      UserAccount(id: 'u1', username: 'admin', password: '123', role: 'Admin'),
      UserAccount(id: 'u2', username: 'operator', password: '123', role: 'User'),
    ]);

    // Standard Demo Destinations (mapped to sources s1 and s2 for sharing stability)
    final sampleDestinations = [
      Device(id: 'd1', name: 'Lobby Display', ip: '192.168.1.51', type: DeviceType.rx, status: DeviceStatus.online, location: 'Guest Areas'),
      Device(id: 'd2', name: 'Kitchen TV', ip: '192.168.1.52', type: DeviceType.rx, status: DeviceStatus.online, location: 'Guest Areas'),
      Device(id: 'd3', name: 'Master Bed Room', ip: '192.168.1.53', type: DeviceType.rx, status: DeviceStatus.online, location: 'Private Quarters'),
      Device(id: 'd4', name: 'Main Hall', ip: '192.168.1.54', type: DeviceType.rx, status: DeviceStatus.online, location: 'Private Quarters'),
      Device(id: 'd5', name: 'Patio Screen', ip: '192.168.1.55', type: DeviceType.rx, status: DeviceStatus.online, location: 'Outdoor'),
    ];

    for (var dest in sampleDestinations) {
      if (!destinationsByLocation.containsKey(dest.location)) {
        destinationsByLocation[dest.location] = [];
      }
      destinationsByLocation[dest.location]!.add(dest);
    }

    // Standard Sample Snapshots
    if (savedSnapshots.isEmpty) {
      savedSnapshots.addAll([
        {
          'title': 'Game Day Setup',
          'date': '26/02/2026, 20:44:58',
          'routes': 4,
          'matrix': {
            'd1': 's1', // Twitch to Main Display
            'd2': 's1', // Twitch to Confidence
            'd3': 's4', // Xbox to Lobby L
            'd4': 's4', // Xbox to Lobby R
          }
        },
        {
          'title': 'Happy Hour Config',
          'date': '25/02/2026, 20:44:58',
          'routes': 3,
          'matrix': {
            'd1': 's2', // Spotify to Main Display
            'd3': 's2', // Spotify to Lobby L
            'd4': 's2', // Spotify to Lobby R
          }
        },
      ]);
    }

    // Assign default routing paths so all videos play by default
    if (activeRoutes.isEmpty) {
      final allDests = destinationsByLocation.values.expand((element) => element).toList();
      for (int i = 0; i < allDests.length; i++) {
        final sourceIndex = i % sources.length;
        activeRoutes[allDests[i].id] = sources[sourceIndex].id;
      }
    }
  }

  // Forces listeners to rebuild UI
  @override
  void notifyListeners() {
    stateVersionNotifier.value++;
    super.notifyListeners();
  }

  // Clear all routes
  void clearAllRoutes() {
    activeRoutes.clear();
    notifyListeners();
  }

  // Snapshot Recall Method
  void loadSnapshotRoutes(Map<String, String?> snapshotMapping) {
    activeRoutes.clear();
    activeRoutes.addAll(snapshotMapping);
    notifyListeners();
  }
}
