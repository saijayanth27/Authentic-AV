import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/device_model.dart';
import '../widgets/common_widgets.dart';

class OperateModule extends StatefulWidget {
  const OperateModule({super.key});

  @override
  State<OperateModule> createState() => _OperateModuleState();
}

class _OperateModuleState extends State<OperateModule> {
  String? _selectedSourceId;
  final Set<String> _selectedDestinationIds = {};

  final List<Device> _sources = [
    Device(id: 'tx1', name: 'ESPN', ip: '192.168.1.101', type: DeviceType.tx, status: DeviceStatus.online, location: 'Rack 1', tags: ['Sports', 'Live']),
    Device(id: 'tx2', name: 'Netflix', ip: '192.168.1.102', type: DeviceType.tx, status: DeviceStatus.online, location: 'Rack 1', tags: ['Movies']),
    Device(id: 'tx3', name: 'YouTube TV', ip: '192.168.1.103', type: DeviceType.tx, status: DeviceStatus.online, location: 'Rack 2', tags: ['TV']),
    Device(id: 'tx4', name: 'Apple TV', ip: '192.168.1.104', type: DeviceType.tx, status: DeviceStatus.online, location: 'Rack 2', tags: ['Media']),
  ];

  final Map<String, List<Device>> _destinationsByLocation = {
    'Main Bar': [
      Device(id: 'rx1', name: 'Bar Left', ip: '192.168.1.201', type: DeviceType.rx, status: DeviceStatus.online, location: 'Main Bar'),
      Device(id: 'rx2', name: 'Bar Right', ip: '192.168.1.202', type: DeviceType.rx, status: DeviceStatus.online, location: 'Main Bar'),
    ],
    'Lobby': [
      Device(id: 'rx3', name: 'Lobby Primary', ip: '192.168.1.203', type: DeviceType.rx, status: DeviceStatus.online, location: 'Lobby'),
      Device(id: 'rx4', name: 'Lobby Secondary', ip: '192.168.1.204', type: DeviceType.rx, status: DeviceStatus.warning, location: 'Lobby'),
    ],
    'VIP Lounge': [
      Device(id: 'rx5', name: 'VIP 1', ip: '192.168.1.205', type: DeviceType.rx, status: DeviceStatus.online, location: 'VIP Lounge'),
      Device(id: 'rx6', name: 'VIP 2', ip: '192.168.1.206', type: DeviceType.rx, status: DeviceStatus.offline, location: 'VIP Lounge'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: isMobile 
                  ? ListView(
                      children: [
                        _buildStep1(),
                        const SizedBox(height: 32),
                        _buildStep2(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step 1: Select Sources
                        Expanded(
                          flex: 3,
                          child: _buildStep1(),
                        ),
                        const SizedBox(width: 32),
                        // Step 2: Select Destinations
                        Expanded(
                          flex: 2,
                          child: _buildStep2(),
                        ),
                      ],
                    ),
              ),
              // Step 3: Confirm Routing (Footer)
              if (_selectedSourceId != null && _selectedDestinationIds.isNotEmpty)
                _buildRoutingFooter(),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepHeader('1', 'Select Sources', 'Choose a video source to route'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _sources.length,
          itemBuilder: (context, index) {
            final source = _sources[index];
            final isSelected = _selectedSourceId == source.id;
            return _buildSourceCard(source, isSelected);
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('2', 'Select Destinations', 'Choose where to display the source'),
        const SizedBox(height: 16),
        ..._destinationsByLocation.entries.map((entry) {
          return _buildLocationAccordion(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildStepHeader(String step, String title, String subtitle) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppTheme.primaryTeal,
          child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle, 
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceCard(Device source, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSourceId = isSelected ? null : source.id;
        });
      },
      child: AvCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Center(
                    child: Icon(Icons.play_circle_outline, size: 40, color: Colors.grey[400]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            source.name, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildStatusIndicator(source.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      source.ip, 
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: source.tags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: AvBadge(text: tag, color: Colors.blueGrey),
                        )).toList(),
                      ),
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

  Widget _buildLocationAccordion(String name, List<Device> devices) {
    return ExpansionTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      initiallyExpanded: true,
      children: devices.map((device) {
        final isSelected = _selectedDestinationIds.contains(device.id);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedDestinationIds.add(device.id);
              } else {
                _selectedDestinationIds.remove(device.id);
              }
            });
          },
          title: Text(device.name, style: const TextStyle(fontSize: 13)),
          subtitle: Text(device.ip, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          secondary: _buildStatusIndicator(device.status),
          activeColor: AppTheme.primaryTeal,
        );
      }).toList(),
    );
  }

  Widget _buildStatusIndicator(DeviceStatus status) {
    Color color;
    switch (status) {
      case DeviceStatus.online: color = Colors.green; break;
      case DeviceStatus.warning: color = Colors.orange; break;
      case DeviceStatus.offline: color = Colors.red; break;
      case DeviceStatus.pending: color = Colors.blue; break;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildRoutingFooter() {
    final sourceName = _sources.firstWhere((s) => s.id == _selectedSourceId).name;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Route $sourceName to ${_selectedDestinationIds.length} destinations?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'This will update the routing configuration immediately.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() {
                  _selectedSourceId = null;
                  _selectedDestinationIds.clear();
                }),
                child: const Text('Clear', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Routing updated successfully!')),
                  );
                  setState(() {
                    _selectedSourceId = null;
                    _selectedDestinationIds.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryTeal,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Confirm Routing'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
