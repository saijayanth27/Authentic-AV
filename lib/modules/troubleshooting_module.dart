import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TroubleshootingModule extends StatefulWidget {
  const TroubleshootingModule({super.key});

  @override
  State<TroubleshootingModule> createState() => _TroubleshootingModuleState();
}

class _TroubleshootingModuleState extends State<TroubleshootingModule> {
  String? _selectedDeviceId;

  final List<Map<String, dynamic>> _destinations = [
    {'id': 'rx1', 'name': 'Bar Display 1', 'location': 'Main Bar', 'ip': '192.168.1.201', 'status': 'Online'},
    {'id': 'rx2', 'name': 'Bar Display 2', 'location': 'Main Bar', 'ip': '192.168.1.202', 'status': 'Online'},
    {'id': 'rx3', 'name': 'Lobby Screen', 'location': 'Lobby', 'ip': '192.168.1.203', 'status': 'Online'},
    {'id': 'rx4', 'name': 'Patio Display', 'location': 'Outdoor Patio', 'ip': '192.168.1.204', 'status': 'Offline'},
  ];

  void _showDiagnosticsTerminal(Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiagnosticsTerminalModal(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Dense dashboard layout
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Troubleshooting', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    const SizedBox(height: 4),
                    const Text('Diagnose and resolve endpoint issues', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text('1 Issue Detected', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 200, // expanded height to dynamically prevent text clipping
            ),
            itemCount: _destinations.length,
            itemBuilder: (context, index) {
              final dev = _destinations[index];
              final isOnline = dev['status'] == 'Online';
              final isSelected = dev['id'] == _selectedDeviceId;
              return GestureDetector(
                onTap: () => setState(() => _selectedDeviceId = dev['id'] as String),
                child: AvCard(
                  padding: EdgeInsets.zero,
                  isSelected: isSelected,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isOnline ? AppTheme.accentWhite.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isOnline ? Icons.router : Icons.error_outline, 
                              color: isOnline ? AppTheme.accentWhite : Colors.redAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dev['name']!, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    AvBadge(
                                      text: dev['status']!, 
                                      color: isOnline ? Colors.green : Colors.redAccent,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        dev['location']!, 
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'IP: ${dev['ip']}', 
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDiagnosticsTerminal(dev),
                          icon: const Icon(Icons.analytics_outlined, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Run Diagnostics', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isSelected ? AppTheme.backgroundLight : AppTheme.accentWhite,
                            backgroundColor: isSelected ? AppTheme.accentWhite : Colors.transparent,
                            side: const BorderSide(color: AppTheme.accentWhite),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          ),
        ],
      ),
    );
  }
}


class _DiagnosticsTerminalModal extends StatefulWidget {
  final Map<String, dynamic> device;

  const _DiagnosticsTerminalModal({required this.device});

  @override
  State<_DiagnosticsTerminalModal> createState() => _DiagnosticsTerminalModalState();
}

class _DiagnosticsTerminalModalState extends State<_DiagnosticsTerminalModal> {
  final List<String> _logs = [];
  bool _isFinished = false;
  late Timer _timer;
  int _step = 0;
  final ScrollController _scrollCtrl = ScrollController();

  final List<String> _sequence = [
    'Initializing secure SSH tunnel to [IP]...',
    'Tunnel established on Port 22.',
    'Pinging remote host...',
    'Reply from [IP]: bytes=32 time=4ms TTL=64',
    'Reply from [IP]: bytes=32 time=3ms TTL=64',
    'Querying HDCP Handshake status...',
    'HDCP status: AUTHENTICATED 2.2',
    'Verifying IGMP Multicast joins...',
    'Group 239.0.0.1 : ACTIVE',
    'Packet loss analysis routine running...',
    '0.00% Packet loss detected.',
    'System Health: [STATUS]',
    'Diagnostics routine successfully terminated.',
  ];

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      if (_step < _sequence.length) {
        setState(() {
          String log = _sequence[_step]
              .replaceAll('[IP]', widget.device['ip'])
              .replaceAll('[STATUS]', widget.device['status'] == 'Online' ? 'EXCELLENT' : 'CRITICAL ERRORS');
          _logs.add(log);
          _step++;
        });
        
        // Auto scroll to latest log
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() => _isFinished = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Diagnostics: ${widget.device['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('IP: ${widget.device['ip']}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontFamily: 'Courier')),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          
          // Terminal Window
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView.builder(
                controller: _scrollCtrl,
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '> ${_logs[index]}',
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 14,
                        color: Colors.greenAccent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Footer Actions
          if (_isFinished)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Reboot Device'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.accentWhite,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Acknowledge'),
                    ),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: LinearProgressIndicator(color: Colors.greenAccent, backgroundColor: Colors.white10),
            )
        ],
      ),
    );
  }
}
