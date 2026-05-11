import 'package:shared_preferences/shared_preferences.dart';
import '../models/vault_item.dart';

class VaultService {
  static const String _storageKey = 'vault_items';

  static Future<void> saveItem(VaultItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAllItems();
    existing.insert(0, item);
    final encoded = existing.map((i) => i.encode()).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  static Future<List<VaultItem>> getAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw.map((s) => VaultItem.decode(s)).toList();
  }

  static Future<void> deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAllItems();
    existing.removeWhere((i) => i.id == id);
    final encoded = existing.map((i) => i.encode()).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}
