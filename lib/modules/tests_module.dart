import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TestsModule extends StatelessWidget {
  const TestsModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Health Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Verification results for system components', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildTestResult('UI Rendering Engine', 'PASS', Colors.green),
                _buildTestResult('Device Discovery Service', 'PASS', Colors.green),
                _buildTestResult('Network Multicast Routing', 'WARNING', Colors.orange),
                _buildTestResult('Database Sync Status', 'PENDING', Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResult(String component, String status, Color color) {
    return AvCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(component, style: const TextStyle(fontWeight: FontWeight.w500)),
          AvBadge(text: status, color: color),
        ],
      ),
    );
  }
}
