import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../shared/styles/markdown_style.dart';
import '../../shared/widgets/selection_search_app_bar.dart';
import '../../shared/widgets/code_element_builder.dart';
import 'models/vault_item.dart';
import 'services/vault_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<VaultItem> _items = [];
  bool _isLoading = true;
  final FlutterTts _flutterTts = FlutterTts();
  int? _speakingIndex;

  bool _isSearching = false;
  String _searchQuery = '';
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadVaultItems();
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() { _speakingIndex = null; });
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() { _speakingIndex = null; });
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadVaultItems() async {
    final items = await VaultService.getAllItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(String id) async {
    await VaultService.deleteItem(id);
    _loadVaultItems();
  }
  
  Future<void> _deleteSelectedItems() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Selected', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${_selectedIds.length} item(s)?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              for (final id in _selectedIds) {
                await VaultService.deleteItem(id);
              }
              setState(() {
                _isSelecting = false;
                _selectedIds.clear();
              });
              _loadVaultItems();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $time';
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete from Vault', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to remove this message from your Vault?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteItem(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelecting = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: SelectionSearchAppBar(
        title: 'Vault',
        isSearching: _isSearching,
        isSelecting: _isSelecting,
        selectedCount: _selectedIds.length,
        onSearchChanged: (val) => setState(() => _searchQuery = val),
        onSearchToggle: () => setState(() {
          _isSearching = true;
          _isSelecting = false;
          _selectedIds.clear();
        }),
        onSearchClose: () => setState(() {
          _isSearching = false;
          _searchQuery = '';
        }),
        onSelectToggle: () => setState(() {
          _isSelecting = true;
          _isSearching = false;
          _searchQuery = '';
        }),
        onSelectClose: () => setState(() {
          _isSelecting = false;
          _selectedIds.clear();
        }),
        onDeleteSelected: _deleteSelectedItems,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white54))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.white24, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Vault is empty',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Save important messages here to keep them forever',
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No matches found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isUser = item.role == 'user';
                        final isSelected = _selectedIds.contains(item.id);

                        return GestureDetector(
                          onLongPress: () {
                            if (!_isSelecting) {
                              setState(() {
                                _isSelecting = true;
                                _selectedIds.add(item.id);
                              });
                            }
                          },
                          onTap: () {
                            if (_isSelecting) {
                              _toggleSelection(item.id);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? Colors.blueAccent : Colors.white10,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isUser ? Icons.person_outline : Icons.smart_toy_outlined,
                                      color: Colors.white54,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isUser ? 'You' : 'Friday',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDate(item.savedAt),
                                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                isUser
                                    ? Text(
                                        item.content,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                      )
                                    : MarkdownBody(
                                        data: item.content,
                                        selectable: !_isSelecting,
                                        styleSheet: chatMarkdownStyle(),
                                        builders: {
                                          'code': CodeElementBuilder(),
                                        },
                                      ),
                                const SizedBox(height: 16),
                                if (!_isSelecting)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.copy, color: Colors.white38, size: 18),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: item.content));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.share, color: Colors.white38, size: 18),
                                        onPressed: () => Share.share(item.content),
                                      ),
                                      const SizedBox(width: 16),
                                      if (_speakingIndex == index)
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.stop, color: Colors.redAccent, size: 18),
                                          onPressed: () async {
                                            await _flutterTts.stop();
                                            setState(() => _speakingIndex = null);
                                          },
                                        )
                                      else
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.volume_up, color: Colors.white38, size: 18),
                                          onPressed: () async {
                                            await _flutterTts.stop();
                                            setState(() => _speakingIndex = index);
                                            await _flutterTts.speak(item.content);
                                          },
                                        ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
                                        onPressed: () => _showDeleteConfirmation(item.id),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
