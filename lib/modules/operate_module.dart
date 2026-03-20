import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/device_model.dart';

class OperateModule extends StatefulWidget {
  const OperateModule({super.key});

  @override
  State<OperateModule> createState() => _OperateModuleState();
}

class _OperateModuleState extends State<OperateModule> {
  final Set<String> _selectedSourceIds = {};
  final Set<String> _selectedDestinationIds = {};
  final Map<String, String?> _activeRoutes = {}; // destinationId -> sourceId
  String _searchQuery = '';
  String _activeTagFilter = 'All';
  final Map<String, bool> _expandedLocations = {};

  // ── Sources ──────────────────────────────────────────────────────────────
  final List<Device> _sources = [
    Device(
      id: 'tx1',
      name: 'ESPN Feed',
      ip: '192.168.1.101',
      type: DeviceType.tx,
      status: DeviceStatus.online,
      location: 'Equipment Room',
      tags: ['ESPN'],
      previewUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
    ),
    Device(
      id: 'tx2',
      name: 'YouTube TV',
      ip: '192.168.1.103',
      type: DeviceType.tx,
      status: DeviceStatus.online,
      location: 'Equipment Room',
      tags: ['YOUTUBE'],
      previewUrl: 'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=400&q=80',
    ),
    Device(
      id: 'tx3',
      name: 'Apple TV 4K',
      ip: '192.168.1.104',
      type: DeviceType.tx,
      status: DeviceStatus.online,
      location: 'Equipment Room',
      tags: ['APPLE'],
      previewUrl: 'https://images.unsplash.com/photo-1621768216002-5ac171661f1b?w=400&q=80',
    ),
    Device(
      id: 'tx4',
      name: 'HDMI Input 1',
      ip: '192.168.1.104',
      type: DeviceType.tx,
      status: DeviceStatus.online,
      location: 'Equipment Room',
      tags: ['HDMI'],
      previewUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
    ),
    Device(
      id: 'tx5',
      name: 'Netflix',
      ip: '192.168.1.102',
      type: DeviceType.tx,
      status: DeviceStatus.online,
      location: 'Equipment Room',
      tags: ['NETFLIX'],
      previewUrl: 'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?w=400&q=80',
    ),
  ];

  // ── Destinations by location ──────────────────────────────────────────────
  final Map<String, List<Device>> _destinationsByLocation = {
    'Main Bar': [
      Device(id: 'rx1', name: 'Bar Display 1', ip: '192.168.1.201', type: DeviceType.rx, status: DeviceStatus.online, location: 'Main Bar'),
      Device(id: 'rx2', name: 'Bar Display 2', ip: '192.168.1.202', type: DeviceType.rx, status: DeviceStatus.online, location: 'Main Bar'),
    ],
    'Lobby': [
      Device(id: 'rx3', name: 'Lobby Screen', ip: '192.168.1.203', type: DeviceType.rx, status: DeviceStatus.online, location: 'Lobby'),
    ],
    'Outdoor Patio': [
      Device(id: 'rx4', name: 'Patio Display', ip: '192.168.1.204', type: DeviceType.rx, status: DeviceStatus.online, location: 'Outdoor Patio'),
    ],
  };

  List<String> get _allTags {
    final tags = <String>{'All'};
    for (final s in _sources) {
      tags.addAll(s.tags);
    }
    return tags.toList();
  }

  List<Device> get _filteredSources {
    return _sources.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.ip.contains(_searchQuery);
      final matchesTag = _activeTagFilter == 'All' || s.tags.contains(_activeTagFilter);
      return matchesSearch && matchesTag;
    }).toList();
  }

  List<Device> get _allDestinations =>
      _destinationsByLocation.values.expand((d) => d).toList();

  @override
  void initState() {
    super.initState();
    for (final loc in _destinationsByLocation.keys) {
      _expandedLocations[loc] = true;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStep1(), // Sources first
                const SizedBox(height: 28),
                _buildStep2(), // Destinations second
              ],
            ),
          ),
        ),
        if (_selectedSourceIds.isNotEmpty || _selectedDestinationIds.isNotEmpty)
          _buildRoutingFooter(),
      ],
    );
  }

  // ── Step 1 ────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          '1',
          'Select Sources',
          'Choose one or more video sources (${_selectedSourceIds.length} selected)',
        ),
        const SizedBox(height: 14),
        // Search bar
        SizedBox(
          height: 40,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search sources...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Tag filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _allTags.map((tag) {
              final isActive = _activeTagFilter == tag;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _activeTagFilter = tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryPurple : Colors.white,
                      border: Border.all(
                        color: isActive ? AppTheme.primaryPurple : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Source cards grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: _filteredSources.length,
          itemBuilder: (context, i) {
            final src = _filteredSources[i];
            return _buildSourceCard(src);
          },
        ),
      ],
    );
  }

  Widget _buildSourceCard(Device source) {
    final isSelected = _selectedSourceIds.contains(source.id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSourceIds.remove(source.id);
          } else {
            _selectedSourceIds.add(source.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: source.previewUrl != null
                  ? Image.network(
                      source.previewUrl!,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderThumb(height: 90),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _placeholderThumb(height: 90),
                    )
                  : _placeholderThumb(height: 90),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TX badge + status dot
                  Row(
                    children: [
                      _deviceTypeBadge('TX'),
                      const Spacer(),
                      _statusDot(source.status),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    source.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 11, color: Colors.grey.shade500),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          source.location,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    source.ip,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    children: source.tags.map((tag) => _tagChip(tag)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumb({double height = 90}) => Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Icon(Icons.tv, size: 32, color: Colors.grey.shade400),
      );

  // ── Step 2 ────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          '2',
          'Select Destinations',
          'Choose one or more displays (${_selectedDestinationIds.length} selected)',
        ),
        const SizedBox(height: 14),
        // Location accordions
        ..._destinationsByLocation.entries.map((entry) {
          return _buildLocationGroup(entry.key, entry.value);
        }),
        const SizedBox(height: 20),
        // Destination previews
        _buildDestinationPreviews(),
      ],
    );
  }

  Widget _buildLocationGroup(String location, List<Device> devices) {
    final isExpanded = _expandedLocations[location] ?? true;
    final selectedCount = devices.where((d) => _selectedDestinationIds.contains(d.id)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expandedLocations[location] = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Text(
                    location,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                  if (selectedCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$selectedCount selected',
                        style: TextStyle(fontSize: 11, color: AppTheme.primaryPurple, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                ),
                itemCount: devices.length,
                itemBuilder: (ctx, i) => _buildDestCard(devices[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDestCard(Device device) {
    final isSelected = _selectedDestinationIds.contains(device.id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDestinationIds.remove(device.id);
          } else {
            _selectedDestinationIds.add(device.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withValues(alpha: 0.06) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ] : [],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _deviceTypeBadge('RX'),
                const Spacer(),
                _statusDot(device.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              device.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 10, color: Colors.grey.shade400),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    device.location,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              device.ip,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationPreviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Destination Previews',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Current routing status for all displays',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _allDestinations.length,
          itemBuilder: (ctx, i) {
            final dest = _allDestinations[i];
            final isActive = _selectedDestinationIds.contains(dest.id);
            return Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppTheme.primaryPurple : Colors.grey.shade800,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMonitorContent(dest),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dest.name,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                dest.location,
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'ID',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
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
    final routedSource = routedSourceId != null ? _sources.firstWhere((s) => s.id == routedSourceId) : null;

    if (routedSource != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          routedSource.previewUrl != null
              ? Image.network(
                  routedSource.previewUrl!,
                  fit: BoxFit.cover,
                )
              : Container(color: Colors.black),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                routedSource.name,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Center(
            child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 30),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.monitor, size: 36, color: Colors.grey.shade600),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'rx online',
                style: TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
          ),
          Center(
            child: Text(
              'NO SIGNAL',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.1), fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3 Footer ─────────────────────────────────────────────────────────
  Widget _buildRoutingFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selectedSourceIds.length} source(s) selected',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
                ),
                Text(
                  'Targeting ${_selectedDestinationIds.length} display(s)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _selectedSourceIds.clear();
              _selectedDestinationIds.clear();
            }),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: (_selectedSourceIds.isNotEmpty && _selectedDestinationIds.isNotEmpty)
                ? () {
                    setState(() {
                      final firstSourceId = _selectedSourceIds.first;
                      for (final destId in _selectedDestinationIds) {
                        _activeRoutes[destId] = firstSourceId;
                      }
                      _selectedSourceIds.clear();
                      _selectedDestinationIds.clear();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('Routing updated successfully!'),
                          ],
                        ),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Confirm Route', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _buildStepHeader(String step, String title, String subtitle) {
    return Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: AppTheme.primaryPurple,
          child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deviceTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _statusDot(DeviceStatus status) {
    Color color;
    switch (status) {
      case DeviceStatus.online:
        color = Colors.green;
        break;
      case DeviceStatus.warning:
        color = Colors.orange;
        break;
      case DeviceStatus.offline:
        color = Colors.red;
        break;
      case DeviceStatus.pending:
        color = Colors.blue;
        break;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Text(
        tag,
        style: TextStyle(fontSize: 9, color: Colors.blueGrey.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }
}
