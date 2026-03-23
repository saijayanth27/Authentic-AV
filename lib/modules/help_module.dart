import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpModule extends StatefulWidget {
  const HelpModule({super.key});

  @override
  State<HelpModule> createState() => _HelpModuleState();
}

class _HelpModuleState extends State<HelpModule> {
  String _searchQuery = '';

  final List<Map<String, String>> _allTerms = const [
    {
      'term': 'Transmitter (TX)',
      'category': 'Hardware',
      'def': 'Encodes HDMI video and audio into IP packets for transmission across the network.',
    },
    {
      'term': 'Receiver (RX)',
      'category': 'Hardware',
      'def': 'Decodes IP packets back into HDMI video and audio for displays.',
    },
    {
      'term': 'Encoder',
      'category': 'Hardware',
      'def': 'Hardware that compresses and converts raw AV signals to an IP stream.',
    },
    {
      'term': 'Decoder',
      'category': 'Hardware',
      'def': 'Hardware that receives an IP stream and outputs raw AV signals.',
    },
    {
      'term': 'Multicast',
      'category': 'Networking',
      'def': 'One-to-many communication for efficient video distribution across a network switch.',
    },
    {
      'term': 'Unicast',
      'category': 'Networking',
      'def': 'One-to-one communication, typically used for control or isolated diagnostic streams.',
    },
    {
      'term': 'IGMP Snooping',
      'category': 'Networking',
      'def': 'Network switch feature that prevents multicast flooding by inspecting traffic and forwarding only to subscribed ports.',
    },
    {
      'term': 'Device Adoption',
      'category': 'Control',
      'def': 'The process of adding a discovered, unmanaged device to your active control system.',
    },
    {
      'term': 'EDID',
      'category': 'Video',
      'def': 'Extended Display Identification Data. Information sent from a display to a source detailing its video and audio capabilities.',
    },
    {
      'term': 'HDCP',
      'category': 'Video',
      'def': 'High-bandwidth Digital Content Protection. Encryption protocol to prevent unauthorized copying of digital AV content.',
    },
    {
      'term': 'PoE (Power over Ethernet)',
      'category': 'Infrastructure',
      'def': 'Technology that delivers DC power and data over a single twisted-pair Ethernet cable.',
    },
    {
      'term': 'Latency',
      'category': 'Metric',
      'def': 'The absolute time delay between capturing an AV signal at the source and outputting it at the display (typically measured in frames).',
    },
    {
      'term': 'Subnet Mask',
      'category': 'Networking',
      'def': 'A 32-bit number that masks an IP address, separating the network address from the host isolation block.',
    },
    {
      'term': 'VLAN',
      'category': 'Networking',
      'def': 'Virtual Local Area Network. A logically isolated network segment created on a managed network switch.',
    },
    {
      'term': 'Dante / AES67',
      'category': 'Audio',
      'def': 'Audio-over-IP networking protocols for distributing zero-latency, uncompressed digital audio over a local area network.',
    },
  ];

  List<Map<String, String>> get _filteredTerms {
    if (_searchQuery.isEmpty) return _allTerms;
    return _allTerms.where((item) {
      final term = item['term']!.toLowerCase();
      final def = item['def']!.toLowerCase();
      final q = _searchQuery.toLowerCase();
      return term.contains(q) || def.contains(q);
    }).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hardware': return Icons.router_outlined;
      case 'Networking': return Icons.hub_outlined;
      case 'Control': return Icons.admin_panel_settings_outlined;
      case 'Video': return Icons.hd_outlined;
      case 'Audio': return Icons.graphic_eq_outlined;
      case 'Infrastructure': return Icons.electrical_services_outlined;
      case 'Metric': return Icons.speed_outlined;
      default: return Icons.info_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hardware': return Colors.white;
      case 'Networking': return Colors.blueAccent;
      case 'Control': return Colors.orangeAccent;
      case 'Video': return Colors.purpleAccent;
      case 'Audio': return Colors.redAccent;
      case 'Infrastructure': return Colors.greenAccent;
      case 'Metric': return Colors.yellowAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Help & Glossary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  SizedBox(height: 4),
                  Text('Quick tips and AVoIP terminology reference', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
              const Spacer(),
              if (!isMobile) _buildSearchBar(width: 300),
            ],
          ),
          
          if (isMobile) ...[
            const SizedBox(height: 20),
            _buildSearchBar(width: double.infinity),
          ],
          
          const SizedBox(height: 32),
          
          // Glossary Grid
          Expanded(
            child: _filteredTerms.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    crossAxisSpacing: isMobile ? 12 : 20,
                    mainAxisSpacing: isMobile ? 12 : 20,
                    mainAxisExtent: 140, // Height of the glossary card
                  ),
                  itemCount: _filteredTerms.length,
                  itemBuilder: (context, index) {
                    final item = _filteredTerms[index];
                    return _buildGlossaryCard(item);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({required double width}) {
    return SizedBox(
      width: width,
      height: 40,
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search terminology...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search_outlined, color: Colors.grey, size: 18),
          filled: true,
          fillColor: AppTheme.highlightGrey,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.accentWhite),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            'No terms found for "$_searchQuery".',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGlossaryCard(Map<String, String> item) {
    final catColor = _getCategoryColor(item['category']!);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.highlightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item['term']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.accentWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: catColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getCategoryIcon(item['category']!), size: 10, color: catColor),
                    const SizedBox(width: 4),
                    Text(
                      item['category']!,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: catColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Definition Body
          Expanded(
            child: Text(
              item['def']!,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
