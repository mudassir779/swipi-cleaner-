import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

/// Recently deleted photo item
class DeletedPhoto {
  final String id;
  final DateTime deletedAt;
  final AssetEntity asset;

  DeletedPhoto({
    required this.id,
    required this.deletedAt,
    required this.asset,
  });

  /// Days remaining until permanent deletion
  int get daysRemaining {
    final daysSinceDeleted = DateTime.now().difference(deletedAt).inDays;
    return 30 - daysSinceDeleted;
  }

  /// Check if expired (past 30 days)
  bool get isExpired {
    return daysRemaining <= 0;
  }
}

/// Provider for recently deleted photos
final recentlyDeletedProvider =
    StateNotifierProvider<RecentlyDeletedNotifier, List<DeletedPhoto>>((ref) {
  return RecentlyDeletedNotifier();
});

class RecentlyDeletedNotifier extends StateNotifier<List<DeletedPhoto>> {
  RecentlyDeletedNotifier() : super([]) {
    _cleanupExpired();
  }

  /// Add photo to recently deleted
  void add(String id, AssetEntity asset) {
    state = [
      ...state.where((item) => item.id != id),
      DeletedPhoto(
        id: id,
        deletedAt: DateTime.now(),
        asset: asset,
      ),
    ];
  }

  /// Add multiple photos
  void addAll(List<MapEntry<String, AssetEntity>> items) {
    final newItems = items.map((entry) => DeletedPhoto(
      id: entry.key,
      deletedAt: DateTime.now(),
      asset: entry.value,
    )).toList();

    final existingIds = newItems.map((i) => i.id).toSet();
    state = [
      ...state.where((item) => !existingIds.contains(item.id)),
      ...newItems,
    ];
  }

  /// Remove from recently deleted
  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// Restore photo (remove from recently deleted)
  void restore(String id) {
    remove(id);
  }

  /// Clear all
  void clear() {
    state = [];
  }

  /// Clean up expired items (older than 30 days)
  void _cleanupExpired() {
    state = state.where((item) => !item.isExpired).toList();
  }

  /// Get count
  int get count => state.length;
}
