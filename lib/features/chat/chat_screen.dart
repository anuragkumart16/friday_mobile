import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../menu/menu_screen.dart';
import '../vault/vault_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with icon buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
                      },
                    ),
                  ),
                  // Vault button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultScreen()));
                      },
                    ),
                  ),
                ],
              ),
            ),

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
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                message['content'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        }

                        // Bot message — rendered markdown, no bubble
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: MarkdownBody(
                            data: message['content'] ?? '',
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
                              h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              h3: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                              listBullet: const TextStyle(color: Colors.white, fontSize: 15),
                              strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                              code: const TextStyle(color: Color(0xFF89D4CF), fontSize: 14, fontFamily: 'monospace'),
                              codeblockDecoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              codeblockPadding: const EdgeInsets.all(12),
                              blockquoteDecoration: BoxDecoration(
                                border: Border(left: BorderSide(color: Colors.white24, width: 3)),
                              ),
                              blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                              horizontalRuleDecoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.white12, width: 1)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom input bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  // Plus button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add, color: Colors.white, size: 22),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white10,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button (up arrow in circle)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
