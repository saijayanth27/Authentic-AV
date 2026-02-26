enum DeviceStatus { online, offline, pending, warning }
enum DeviceType { tx, rx }

class Device {
  final String id;
  final String name;
  final String ip;
  final DeviceType type;
  final DeviceStatus status;
  final String? previewUrl;
  final String location;
  final List<String> tags;

  Device({
    required this.id,
    required this.name,
    required this.ip,
    required this.type,
    required this.status,
    this.previewUrl,
    required this.location,
    this.tags = const [],
  });
}
