import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AiAssistantModule extends StatefulWidget {
  const AiAssistantModule({super.key});

  @override
  State<AiAssistantModule> createState() => _AiAssistantModuleState();
}

class _AiAssistantModuleState extends State<AiAssistantModule> {
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': 'Hello! I am your Authentic AV Assistant. How can I help you today?'},
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': _controller.text});
      _controller.clear();
    });
    // Mock response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': 'I am analyzing your system setup... Everything looks good on VLAN 10.'});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAssistant = msg['role'] == 'assistant';
                return Align(
                  alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAssistant ? Colors.white : AppTheme.primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(color: isAssistant ? Colors.black87 : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about your AV system...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppTheme.primaryTeal,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
