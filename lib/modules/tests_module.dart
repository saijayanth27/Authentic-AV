import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class TestsModule extends StatefulWidget {
  const TestsModule({super.key});

  @override
  State<TestsModule> createState() => _TestsModuleState();
}

class _TestsModuleState extends State<TestsModule> {
  bool _isRunning = false;
  double _progress = 0.0;
  
  // Fake state tracking for the animated diagnostic sweep
  final List<Map<String, dynamic>> _tests = [
    {
      'name': 'API Gateway Routing',
      'category': 'Network',
      'status': 'PASS',
      'color': Colors.greenAccent,
      'latency': '12ms',
      'uptime': '99.99%',
      'logs': [
        '[INFO] Resolving endpoint map...',
        '[OK] Gateway handshake established.',
        '[INFO] Authorized internal certificate.'
      ]
    },
    {
      'name': 'Multicast Packet Stream',
      'category': 'Network',
      'status': 'WARNING',
      'color': Colors.orangeAccent,
      'latency': '145ms',
      'uptime': '98.50%',
      'logs': [
        '[INFO] Querying IGMP snooping tables...',
        '[WARN] Packet drop detected on switch port 4.',
        '[INFO] Fallback stream initiated safely.'
      ]
    },
    {
      'name': 'Hardware Video Decoders',
      'category': 'System',
      'status': 'PASS',
      'color': Colors.greenAccent,
      'latency': '2ms',
      'uptime': '100.0%',
      'logs': [
        '[INFO] Allocating surface texture instances...',
        '[OK] Engine buffer locked dynamically.',
        '[OK] 60fps synchronous tick valid.'
      ]
    },
    {
      'name': 'Global Database Registry',
      'category': 'Data',
      'status': 'FAIL',
      'color': Colors.redAccent,
      'latency': 'TIMEOUT',
      'uptime': 'N/A',
      'logs': [
        '[INFO] Pinging external snapshot server...',
        '[ERR] Socket connection refused.',
        '[CRITICAL] Falling back to offline local cache mechanism.'
      ]
    },
    {
      'name': 'Security Handshake Auth',
      'category': 'Security',
      'status': 'PASS',
      'color': Colors.greenAccent,
      'latency': '8ms',
      'uptime': '100.0%',
      'logs': [
        '[INFO] Verifying RBAC role escalations...',
        '[OK] Root administrator credentials verified.',
        '[OK] Token hash signatures validate.'
      ]
    },
  ];

  void _runDiagnostics() {
    setState(() {
      _isRunning = true;
      _progress = 0.0;
    });

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.02;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _isRunning = false;
          timer.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diagnostics Complete. 1 Error Found.'), backgroundColor: Colors.redAccent),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.backgroundLight,
              child: Column(
                children: [
                  // Top Header Area
                  _buildHeader(),
                  
                  // Main Content Scroll
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      itemCount: _tests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildExpandableTestCard(_tests[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diagnostics & Telemetry',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Execute deep system sweeps to analyze Active Logs, Database Integrity, and Hardware Constraints.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isRunning)
                SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Running Analysis... ${(_progress * 100).toInt()}%', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 4,
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentWhite,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _runDiagnostics,
                  icon: const Icon(Icons.radar_outlined, size: 20),
                  label: const Text('Run Full Sweep', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTestCard(Map<String, dynamic> test) {
    Color statusColor = test['color'];
    bool isPending = _isRunning && _progress < 1.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPending ? Colors.blueAccent.withValues(alpha: 0.1) : statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isPending 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
                : Icon(
                    test['status'] == 'PASS' ? Icons.check_circle_outline : test['status'] == 'WARNING' ? Icons.warning_amber_rounded : Icons.error_outline,
                    color: statusColor,
                  ),
          ),
          title: Text(
            test['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  test['category'],
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(
                'Latency: ${isPending ? '--' : test['latency']}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(
                'Uptime: ${isPending ? '--' : test['uptime']}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPending ? Colors.blue.withValues(alpha: 0.2) : statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isPending ? Colors.blue : statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              isPending ? 'PENDING' : test['status'],
              style: TextStyle(
                color: isPending ? Colors.blueAccent : statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Telemetry Execution Logs:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...List.generate((test['logs'] as List).length, (i) {
                    String logLine = test['logs'][i];
                    Color logColor = Colors.white54;
                    if (logLine.contains('[ERR]') || logLine.contains('[CRITICAL]')) logColor = Colors.redAccent;
                    if (logLine.contains('[WARN]')) logColor = Colors.orangeAccent;
                    if (logLine.contains('[OK]')) logColor = Colors.greenAccent;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '> $logLine',
                        style: TextStyle(fontFamily: 'Courier', fontSize: 13, color: logColor),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
