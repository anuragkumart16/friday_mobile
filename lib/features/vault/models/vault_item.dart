import 'dart:convert';

class VaultItem {
  final String id;
  final String content;
  final String role;
  final DateTime savedAt;

  VaultItem({
    required this.id,
    required this.content,
    required this.role,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory VaultItem.fromMap(Map<String, dynamic> map) {
    return VaultItem(
      id: map['id'],
      content: map['content'],
      role: map['role'] ?? 'bot',
      savedAt: DateTime.parse(map['savedAt']),
    );
  }

  String encode() => json.encode(toMap());

  factory VaultItem.decode(String str) => VaultItem.fromMap(json.decode(str));
}
