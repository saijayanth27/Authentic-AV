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
        videoUrl: 'assets/videos/v1.mp4',
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
        videoUrl: 'assets/videos/v2.mp4',
        previewUrl: 'youtube.png',
      ),
      Device(
        id: 's3',
        name: 'Hulu Live TV',
        ip: '192.168.1.103',
        type: DeviceType.tx,
        status: DeviceStatus.warning,
        location: 'Breakroom AV',
        tags: ['Live TV', 'Streaming'],
        videoUrl: 'assets/videos/v3.mp4',
        previewUrl: 'hulu.png',
      ),
      Device(
        id: 's4',
        name: 'Twitch Studio Stream',
        ip: '192.168.1.104',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'Server Room',
        tags: ['Gaming', 'Live Stream'],
        videoUrl: 'assets/videos/v4.mp4',
        previewUrl: 'twitch.png',
      ),
      Device(
        id: 's5',
        name: 'Disney+ Stream',
        ip: '192.168.1.105',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'Theater Room',
        videoUrl: 'assets/videos/v5.mp4',
        tags: ['Movies', 'Streaming'],
        previewUrl: 'disneyplus.png',
      ),
      Device(
        id: 's6',
        name: 'Prime Video',
        ip: '192.168.1.106',
        type: DeviceType.tx,
        status: DeviceStatus.online,
        location: 'AV Rack 2',
        videoUrl: 'assets/videos/v6.mp4',
        tags: ['Movies', 'Streaming'],
        previewUrl: 'primevideo.png',
      ),
    ]);
    
    // Inject Mock Security Database
    users.addAll([
      UserAccount(id: 'u1', username: 'admin', password: '123', role: 'Admin'),
      UserAccount(id: 'u2', username: 'operator', password: '123', role: 'User'),
    ]);

    destinationsByLocation['Home Network'] = [
      Device(id: 'd1', name: 'Lobby', ip: '10.0.0.1', type: DeviceType.rx, status: DeviceStatus.online, location: 'Front', previewUrl: 'main_display.jpg'),
      Device(id: 'd2', name: 'Kitchen', ip: '10.0.0.2', type: DeviceType.rx, status: DeviceStatus.online, location: 'House', previewUrl: 'kitchen.jpg'),
      Device(id: 'd3', name: 'Bed Room', ip: '10.0.0.3', type: DeviceType.rx, status: DeviceStatus.online, location: 'Master', previewUrl: 'bedroom.jpg'),
      Device(id: 'd4', name: 'Hall', ip: '10.0.0.4', type: DeviceType.rx, status: DeviceStatus.online, location: 'Corridor', previewUrl: 'hall.jpg'),
      Device(id: 'd5', name: 'Pool', ip: '10.0.0.5', type: DeviceType.rx, status: DeviceStatus.online, location: 'Patio', previewUrl: 'pool.jpg'),
    ];

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
    if (activeRoutes.isEmpty && destinationsByLocation['Home Network'] != null) {
      final dests = destinationsByLocation['Home Network']!;
      for (int i = 0; i < dests.length; i++) {
        if (i < sources.length) {
          activeRoutes[dests[i].id] = sources[i].id;
        } else {
          activeRoutes[dests[i].id] = sources.first.id;
        }
      }
    }
  }

  // Forces listeners to rebuild UI
  void notifyListeners() {
    stateVersionNotifier.value++;
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
