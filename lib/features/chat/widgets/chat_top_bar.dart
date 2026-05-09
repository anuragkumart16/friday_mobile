import 'package:flutter/material.dart';
import '../../menu/menu_screen.dart';
import '../../vault/vault_screen.dart';

class ChatTopBar extends StatelessWidget {
  const ChatTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
