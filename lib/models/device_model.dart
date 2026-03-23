enum DeviceStatus { online, offline, pending, warning }
enum DeviceType { tx, rx }

class Device {
  final String id;
  String name;
  String ip;
  final DeviceType type;
  final DeviceStatus status;
  final String? previewUrl;
  String location;
  final List<String> tags;
  final String? videoUrl; // Add unique video route feed

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
  });
}
