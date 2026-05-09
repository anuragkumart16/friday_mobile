import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'widgets/chat_top_bar.dart';
import 'widgets/user_message_bubble.dart';
import 'widgets/bot_message_bubble.dart';
import 'widgets/chat_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final FlutterTts _flutterTts = FlutterTts();
  int? _speakingIndex;

  @override
  void initState() {
    super.initState();
    _flutterTts.setCompletionHandler(() {
      setState(() { _speakingIndex = null; });
    });
    _flutterTts.setCancelHandler(() {
      setState(() { _speakingIndex = null; });
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _messages.add({'role': 'bot', 'content': _getExampleResponse()});
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getExampleResponse() {
    return '''
# Welcome to Friday

Here's what I can help you with:

## Features

- **Chat** with natural language
- **Code generation** and debugging
- **Summarization** of long texts

### Ordered Steps

1. Ask me a question
2. I'll process your request
3. Get your answer instantly

---

Here's an example code snippet:

```dart
void main() {
  print('Hello from Friday!');
}
```

> **Note:** I'm still learning, so responses are placeholders for now.

Feel free to ask me anything!
''';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const ChatTopBar(),

            // Chat messages area
            Expanded(
              child: _messages.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message['role'] == 'user';

                        if (isUser) {
                          return UserMessageBubble(content: message['content'] ?? '');
                        }

                        return BotMessageBubble(
                          content: message['content'] ?? '',
                          index: index,
                          speakingIndex: _speakingIndex,
                          flutterTts: _flutterTts,
                          onTtsStop: () {
                            setState(() { _speakingIndex = null; });
                          },
                          onTtsStart: (i) {
                            setState(() { _speakingIndex = i; });
                          },
                        );
                      },
                    ),
            ),

            ChatInputBar(
              messageController: _messageController,
              onSend: _sendMessage,
              onFilesAttached: (fileNames) {
                setState(() {
                  _messages.add({'role': 'user', 'content': '📎 Attached: ${fileNames.join(', ')}'});
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
