import 'package:flutter/material.dart';
import '../../shared/widgets/selection_search_app_bar.dart';
import 'models/bookmarked_chat.dart';
import 'services/bookmark_service.dart';
import '../chat/chat_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<BookmarkedChat> _bookmarks = [];
  bool _isLoading = true;
  
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final chats = await BookmarkService.getAllChats();
    setState(() {
      _bookmarks = chats;
      _isLoading = false;
    });
  }

  Future<void> _deleteBookmark(String id) async {
    await BookmarkService.deleteChat(id);
    _loadBookmarks();
  }

  Future<void> _deleteSelectedBookmarks() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Selected', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${_selectedIds.length} saved chat(s)?',
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
                await BookmarkService.deleteChat(id);
              }
              setState(() {
                _isSelecting = false;
                _selectedIds.clear();
              });
              _loadBookmarks();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} • '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Bookmark', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to remove this saved chat?',
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
              _deleteBookmark(id);
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
    final filteredBookmarks = _bookmarks.where((chat) {
      if (_searchQuery.isEmpty) return true;
      return chat.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: SelectionSearchAppBar(
        title: 'Saved Chats',
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
        onDeleteSelected: _deleteSelectedBookmarks,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white54))
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_border, color: Colors.white24, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'No saved chats yet',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the bookmark icon to save a chat',
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : filteredBookmarks.isEmpty
                  ? const Center(
                      child: Text(
                        'No matches found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: filteredBookmarks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final chat = filteredBookmarks[index];
                        final messageCount = chat.messages.length;
                        final isSelected = _selectedIds.contains(chat.id);

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.white10,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            onLongPress: () {
                              if (!_isSelecting) {
                                setState(() {
                                  _isSelecting = true;
                                  _selectedIds.add(chat.id);
                                });
                              }
                            },
                            onTap: () {
                              if (_isSelecting) {
                                _toggleSelection(chat.id);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ChatScreen(existingChat: chat)),
                                );
                              }
                            },
                            leading: _isSelecting
                                ? Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? Colors.blueAccent : Colors.white38,
                                    size: 28,
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.bookmark, color: Colors.blueAccent, size: 20),
                                  ),
                            title: Text(
                              chat.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '$messageCount messages • ${_formatDate(chat.savedAt)}',
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                            ),
                            trailing: _isSelecting
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white30, size: 20),
                                    onPressed: () => _showDeleteConfirmation(chat.id),
                                  ),
                          ),
                        );
                      },
                    ),
    );
  }
}
