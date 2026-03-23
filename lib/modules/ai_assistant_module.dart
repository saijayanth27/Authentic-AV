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
    {'role': 'assistant', 'content': 'Hello! I am your AuthenticAV Assistant. How can I help you today?'},
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
                      color: isAssistant ? AppTheme.highlightGrey : AppTheme.accentWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(color: isAssistant ? AppTheme.textMain : AppTheme.backgroundLight),
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
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.highlightGrey,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.accentWhite,
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.backgroundLight, size: 20),
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
