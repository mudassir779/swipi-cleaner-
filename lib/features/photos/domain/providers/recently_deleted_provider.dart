import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'photo_provider.dart';

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
  return RecentlyDeletedNotifier(ref);
});

class RecentlyDeletedNotifier extends StateNotifier<AsyncValue<List<RecentlyDeletedItem>>> {
  final Ref ref;
  
  RecentlyDeletedNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadItems();
  }

  /// Load items from system album
  Future<void> _loadItems() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(photoServiceProvider);
      
      // Get items from Recently Deleted album
      final assets = await service.getRecentlyDeletedPhotos();
      
      // Convert to RecentlyDeletedItem
      final items = assets.map((asset) {
        // We don't have exact deletion time from API, so we use modification date
        final date = asset.modifiedDateTime;
        
        return RecentlyDeletedItem(
          photoId: asset.id,
          deletedAt: date, // Using modification date as proxy for deletion time
          asset: asset,
        );
      }).toList();
      
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add item (Stub - system handles this)
  Future<void> addItem(String photoId) async {
    await refresh();
  }

  /// Restore item (Not supported programmatically on all OS, just refresh)
  Future<void> restore(String photoId) async {
    // Note: iOS doesn't allow restoring via API easily without user prompt
    // For now we just refresh the list
    await refresh();
  }

  /// Permanently delete an item
  Future<void> deletePermanently(String photoId) async {
    try {
      // This might prompt the user or fail if not allowed on Recently Deleted

      // PhotoManager deleteWithIds on items already in trash might delete permanently or fail
      // usage: PhotoManager.editor.deleteWithIds([photoId]);
      await PhotoManager.editor.deleteWithIds([photoId]);
    } catch (_) {
      // Ignore errors
    }
    
    // Refresh to update list
    await refresh();
  }

  /// Clear all items
  Future<void> clearAll() async {
    final currentItems = state.value ?? [];
    try {
       final ids = currentItems.map((i) => i.photoId).toList();
       if (ids.isNotEmpty) {
         await PhotoManager.editor.deleteWithIds(ids);
       }
    } catch (_) {}
    
    await refresh();
  }

  /// Refresh items
  Future<void> refresh() async {
    await _loadItems();
  }
}
