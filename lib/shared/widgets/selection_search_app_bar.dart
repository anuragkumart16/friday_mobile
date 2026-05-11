import 'package:flutter/material.dart';

class SelectionSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final bool isSelecting;
  final int selectedCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClose;
  final VoidCallback onSelectToggle;
  final VoidCallback onSelectClose;
  final VoidCallback onDeleteSelected;

  const SelectionSearchAppBar({
    super.key,
    required this.title,
    required this.isSearching,
    required this.isSelecting,
    required this.selectedCount,
    required this.onSearchChanged,
    required this.onSearchToggle,
    required this.onSearchClose,
    required this.onSelectToggle,
    required this.onSelectClose,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelecting) {
      return AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: onSelectClose,
        ),
        title: Text(
          '$selectedCount Selected',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (selectedCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDeleteSelected,
            ),
        ],
        elevation: 0,
      );
    }

    if (isSearching) {
      return AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onSearchClose,
        ),
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          onChanged: onSearchChanged,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onSearchClose,
          ),
        ],
        elevation: 0,
      );
    }

    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: onSearchToggle,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF1A1A1A),
          onSelected: (value) {
            if (value == 'select') {
              onSelectToggle();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'select',
              child: Text('Select', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
