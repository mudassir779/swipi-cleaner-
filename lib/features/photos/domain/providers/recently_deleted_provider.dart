import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for a recently deleted item
class RecentlyDeletedItem {
  final String photoId;
  final DateTime deletedAt;
  final AssetEntity? asset;

  RecentlyDeletedItem({
    required this.photoId,
    required this.deletedAt,
    this.asset,
  });

  /// Days remaining before permanent deletion (30-day retention)
  int get daysRemaining {
    final expiryDate = deletedAt.add(const Duration(days: 30));
    final remaining = expiryDate.difference(DateTime.now()).inDays;
    return remaining.clamp(0, 30);
  }

  /// Check if item has expired
  bool get isExpired => daysRemaining <= 0;
}

/// Provider for recently deleted items
final recentlyDeletedProvider =
    StateNotifierProvider<RecentlyDeletedNotifier, AsyncValue<List<RecentlyDeletedItem>>>((ref) {
  return RecentlyDeletedNotifier();
});

class RecentlyDeletedNotifier extends StateNotifier<AsyncValue<List<RecentlyDeletedItem>>> {
  static const String _storageKey = 'recently_deleted_items';
  
  RecentlyDeletedNotifier() : super(const AsyncValue.loading()) {
    _loadItems();
  }

  /// Load items from storage
  Future<void> _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList(_storageKey) ?? [];
      
      final List<RecentlyDeletedItem> items = [];
      
      for (final json in itemsJson) {
        final parts = json.split('|');
        if (parts.length == 2) {
          final photoId = parts[0];
          final deletedAt = DateTime.tryParse(parts[1]);
          
          if (deletedAt != null) {
            // Try to get the asset
            AssetEntity? asset;
            try {
              asset = await AssetEntity.fromId(photoId);
            } catch (_) {
              // Asset may no longer exist
            }
            
            final item = RecentlyDeletedItem(
              photoId: photoId,
              deletedAt: deletedAt,
              asset: asset,
            );
            
            // Only add if not expired
            if (!item.isExpired) {
              items.add(item);
            }
          }
        }
      }
      
      // Clean up expired items
      await _saveItems(items);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Save items to storage
  Future<void> _saveItems(List<RecentlyDeletedItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items
        .where((item) => !item.isExpired)
        .map((item) => '${item.photoId}|${item.deletedAt.toIso8601String()}')
        .toList();
    await prefs.setStringList(_storageKey, itemsJson);
  }

  /// Add item to recently deleted
  Future<void> addItem(String photoId) async {
    final currentItems = state.value ?? [];
    
    // Check if already exists
    if (currentItems.any((item) => item.photoId == photoId)) return;
    
    AssetEntity? asset;
    try {
      asset = await AssetEntity.fromId(photoId);
    } catch (_) {}
    
    final newItem = RecentlyDeletedItem(
      photoId: photoId,
      deletedAt: DateTime.now(),
      asset: asset,
    );
    
    final updatedItems = [...currentItems, newItem];
    await _saveItems(updatedItems);
    state = AsyncValue.data(updatedItems);
  }

  /// Restore an item (remove from recently deleted)
  Future<void> restore(String photoId) async {
    final currentItems = state.value ?? [];
    final updatedItems = currentItems.where((item) => item.photoId != photoId).toList();
    await _saveItems(updatedItems);
    state = AsyncValue.data(updatedItems);
  }

  /// Permanently delete an item
  Future<void> deletePermanently(String photoId) async {
    try {
      // Actually delete from gallery
      final asset = await AssetEntity.fromId(photoId);
      if (asset != null) {
        await PhotoManager.editor.deleteWithIds([photoId]);
      }
    } catch (_) {
      // May already be deleted
    }
    
    // Remove from our list
    await restore(photoId);
  }

  /// Clear all items
  Future<void> clearAll() async {
    final currentItems = state.value ?? [];
    
    // Delete all from gallery
    for (final item in currentItems) {
      try {
        await PhotoManager.editor.deleteWithIds([item.photoId]);
      } catch (_) {}
    }
    
    // Clear storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    state = const AsyncValue.data([]);
  }

  /// Refresh items
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadItems();
  }
}
