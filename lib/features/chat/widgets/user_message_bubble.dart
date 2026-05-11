import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';


import '../../vault/models/vault_item.dart';
import '../../vault/services/vault_service.dart';

class UserMessageBubble extends StatelessWidget {
  final String content;
  final int index;
  final int? speakingIndex;
  final FlutterTts flutterTts;
  final VoidCallback onTtsStop;
  final ValueChanged<int> onTtsStart;

  const UserMessageBubble({
    super.key,
    required this.content,
    required this.index,
    required this.speakingIndex,
    required this.flutterTts,
    required this.onTtsStop,
    required this.onTtsStart,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Copy
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.copy, color: Colors.white38, size: 16),
                  tooltip: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Share
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.share, color: Colors.white38, size: 16),
                  tooltip: 'Share',
                  onPressed: () {
                    Share.share(content);
                  },
                ),
                const SizedBox(width: 12),
                // Add to Vault
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.lock_outline, color: Colors.white38, size: 16),
                  tooltip: 'Add to Vault',
                  onPressed: () async {
                    final item = VaultItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      content: content,
                      role: 'user',
                      savedAt: DateTime.now(),
                    );
                    await VaultService.saveItem(item);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Vault'), duration: Duration(seconds: 1)),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                // Speaker (TTS)
                if (speakingIndex == index) ...[
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.stop, color: Colors.redAccent, size: 16),
                    tooltip: 'Stop',
                    onPressed: () async {
                      await flutterTts.stop();
                      onTtsStop();
                    },
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.replay, color: Colors.white38, size: 16),
                    tooltip: 'Replay',
                    onPressed: () async {
                      await flutterTts.stop();
                      await flutterTts.speak(content);
                    },
                  ),
                ] else
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.volume_up, color: Colors.white38, size: 16),
                    tooltip: 'Read aloud',
                    onPressed: () async {
                      await flutterTts.stop();
                      onTtsStart(index);
                      await flutterTts.speak(content);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
