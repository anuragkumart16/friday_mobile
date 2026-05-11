import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../settings/services/settings_service.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'widgets/chat_top_bar.dart';
import 'widgets/user_message_bubble.dart';
import 'widgets/bot_message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import '../bookmark/models/bookmarked_chat.dart';
import '../bookmark/services/bookmark_service.dart';
import 'services/chat_history_service.dart';

class ChatScreen extends StatefulWidget {
  final BookmarkedChat? existingChat;

  const ChatScreen({super.key, this.existingChat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, String>> _messages;
  final FlutterTts _flutterTts = FlutterTts();
  late String _sessionId;
  int? _speakingIndex;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.existingChat?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _messages = widget.existingChat != null 
        ? List<Map<String, String>>.from(widget.existingChat!.messages) 
        : [];

    _flutterTts.setCompletionHandler(() {
      setState(() { _speakingIndex = null; });
    });
    _flutterTts.setCancelHandler(() {
      setState(() { _speakingIndex = null; });
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final baseUrl = await SettingsService.getBaseUrl();
      if (baseUrl.isEmpty) {
        setState(() {
          _messages.add({'role': 'bot', 'content': 'Please configure the Remote Setting in Menu > Settings first.'});
        });
        _autoSaveChat();
        _scrollToBottom();
        return;
      }

      final url = Uri.parse('$baseUrl/api/v1/chat');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        String botContent = '';
        if (data is Map) {
          if (data.containsKey('content')) {
            botContent = data['content'].toString();
          } else if (data.containsKey('response')) {
            botContent = data['response'].toString();
          } else if (data.containsKey('message')) {
            botContent = data['message'].toString();
          } else if (data.containsKey('answer')) {
            botContent = data['answer'].toString();
          } else {
            botContent = response.body;
          }
        } else {
          botContent = response.body;
        }

        setState(() {
          _messages.add({'role': 'bot', 'content': botContent});
        });
      } else {
        setState(() {
          _messages.add({'role': 'bot', 'content': 'Error: ${response.statusCode}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Failed to connect: $e'});
      });
    }

    _autoSaveChat();
    _scrollToBottom();
  }

  void _scrollToBottom() {
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


  String _getChatTitle() {
    final firstUserMsg = _messages.firstWhere(
      (m) => m['role'] == 'user',
      orElse: () => {'content': 'Chat'},
    );
    final content = firstUserMsg['content'] ?? 'Chat';
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  void _autoSaveChat() {
    if (_messages.isEmpty) return;
    final chat = BookmarkedChat(
      id: _sessionId,
      title: _getChatTitle(),
      messages: List<Map<String, String>>.from(_messages),
      savedAt: DateTime.now(),
    );
    ChatHistoryService.saveOrUpdate(chat);
  }

  void _bookmarkChat() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No messages to save'),
          backgroundColor: Colors.white24,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final chat = BookmarkedChat(
      id: _sessionId,
      title: _getChatTitle(),
      messages: List<Map<String, String>>.from(_messages),
      savedAt: DateTime.now(),
    );

    await BookmarkService.saveChat(chat);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat saved to bookmarks'),
          backgroundColor: Colors.white24,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _newChat() {
    // Save current chat to history before starting new one
    _autoSaveChat();
    // Replace current screen with a fresh ChatScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
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
            ChatTopBar(onBookmark: _bookmarkChat, onNewChat: _newChat),

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
