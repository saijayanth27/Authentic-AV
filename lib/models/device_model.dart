enum DeviceStatus { online, offline, pending, warning }
enum DeviceType { tx, rx, cx }
enum ViewMode { largeGrid, compactGrid, highDensity, list }

class Device {
  final String id;
  String name;
  String ip;
  final DeviceType type;
  final DeviceStatus status;
  final String? previewUrl;
  String location;
  final List<String> tags;
  final String? videoUrl;
  bool isWinking;

  Device({
    required this.id,
    required this.name,
    required this.ip,
    required this.type,
    required this.status,
    this.previewUrl,
    required this.location,
    this.tags = const [],
    this.videoUrl,
    this.isWinking = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ip': ip,
    'type': type.name,
    'status': status.name,
    'previewUrl': previewUrl,
    'location': location,
    'videoUrl': videoUrl,
  };

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'] as String,
    name: json['name'] as String,
    ip: json['ip'] as String,
    type: DeviceType.values.firstWhere((e) => e.name == json['type'], orElse: () => DeviceType.rx),
    status: DeviceStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => DeviceStatus.online),
    previewUrl: json['previewUrl'] as String?,
    location: json['location'] as String? ?? 'Unassigned',
    videoUrl: json['videoUrl'] as String?,
  );
}
