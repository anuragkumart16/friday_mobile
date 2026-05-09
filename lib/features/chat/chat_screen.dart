import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:markdown/markdown.dart' as md;
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
  final FlutterTts _flutterTts = FlutterTts();
  int? _speakingIndex;
  bool _isSpeaking = false;
  String _currentTtsContent = '';

  @override
  void initState() {
    super.initState();
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _speakingIndex = null;
        _isSpeaking = false;
        _currentTtsContent = '';
      });
    });
    _flutterTts.setCancelHandler(() {
      setState(() {
        _speakingIndex = null;
        _isSpeaking = false;
        _currentTtsContent = '';
      });
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

  String _stripMarkdownForTts(String markdown) {
    String html = md.markdownToHtml(markdown);
    // Add pauses after headings
    html = html.replaceAll('</h1>', '.</h1>');
    html = html.replaceAll('</h2>', '.</h2>');
    html = html.replaceAll('</h3>', '.</h3>');
    html = html.replaceAll('</h4>', '.</h4>');
    // Add pauses after list items
    html = html.replaceAll('</li>', ',</li>');
    // Remove code blocks from speech
    html = html.replaceAll(RegExp('<code>[^<]*</code>'), '');
    html = html.replaceAll(RegExp('<pre>[^<]*</pre>'), '');
    // Strip all HTML tags
    final plainText = html.replaceAll(RegExp('<[^>]*>'), ' ');
    return plainText.split(RegExp('[ \t\n\r]+')).join(' ').trim();
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
                        final content = message['content'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MarkdownBody(
                                data: content,
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
                              const SizedBox(height: 8),
                              // Action buttons row
                              Row(
                                children: [
                                  // Copy
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.white38, size: 18),
                                    tooltip: 'Copy',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: content));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                                      );
                                    },
                                  ),
                                  // Share
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.white38, size: 18),
                                    tooltip: 'Share',
                                    onPressed: () {
                                      Share.share(content);
                                    },
                                  ),
                                  // Add to Vault
                                  IconButton(
                                    icon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                                    tooltip: 'Add to Vault',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Added to Vault'), duration: Duration(seconds: 1)),
                                      );
                                    },
                                  ),
                                  // Speaker (TTS) with controls
                                  if (_speakingIndex == index) ...[
                                    // Stop button
                                    IconButton(
                                      icon: const Icon(Icons.stop, color: Colors.redAccent, size: 18),
                                      tooltip: 'Stop',
                                      onPressed: () async {
                                        await _flutterTts.stop();
                                        setState(() {
                                          _speakingIndex = null;
                                          _isSpeaking = false;
                                          _currentTtsContent = '';
                                        });
                                      },
                                    ),
                                    // Replay button
                                    IconButton(
                                      icon: const Icon(Icons.replay, color: Colors.white38, size: 18),
                                      tooltip: 'Replay',
                                      onPressed: () async {
                                        await _flutterTts.stop();
                                        await _flutterTts.speak(_stripMarkdownForTts(content));
                                      },
                                    ),
                                  ] else
                                    IconButton(
                                      icon: const Icon(Icons.volume_up, color: Colors.white38, size: 18),
                                      tooltip: 'Read aloud',
                                      onPressed: () async {
                                        await _flutterTts.stop();
                                        setState(() {
                                          _speakingIndex = index;
                                          _isSpeaking = true;
                                          _currentTtsContent = _stripMarkdownForTts(content);
                                        });
                                        await _flutterTts.speak(_currentTtsContent);
                                      },
                                    ),
                                ],
                              ),
                            ],
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
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final fileNames = result.files.map((f) => f.name).join(', ');
                          setState(() {
                            _messages.add({'role': 'user', 'content': '📎 Attached: $fileNames'});
                          });
                        }
                      },
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
