import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HelpModule extends StatelessWidget {
  const HelpModule({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Help & Glossary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
          const SizedBox(height: 4),
          const Text('Quick tips and AVoIP terminology reference', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 48),
          const Text('AVoIP Glossary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
          const SizedBox(height: 16),
          _buildGlossaryItem('Transmitter (TX)', 'Encodes HDMI video and audio into IP packets for transmission across the network.'),
          _buildGlossaryItem('Receiver (RX)', 'Decodes IP packets back into HDMI video and audio for displays.'),
          _buildGlossaryItem('Multicast', 'One-to-many communication for efficient video distribution.'),
          _buildGlossaryItem('Device Adoption', 'The process of adding a discovered device to your control system.'),
        ],
      ),
    );
  }

  Widget _buildGlossaryItem(String title, String content) {
    return AvCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryPurple)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: AppTheme.textMain)),
        ],
      ),
    );
  }
}
