import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/deleted_photos_storage.dart';

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
  final DeletedPhotosStorage _storage = DeletedPhotosStorage();
  Timer? _cleanupTimer;

  RecentlyDeletedNotifier() : super([]) {
    _loadFromStorage();
    _setupAutoCleanup();
  }

  /// Load deleted items from storage on initialization
  Future<void> _loadFromStorage() async {
    final items = await _storage.loadDeletedItems();
    // Note: We can't restore AssetEntity from storage, so this is just for metadata tracking
    // The actual photos are already deleted from the device
    // We keep the metadata to show "X days ago" in UI if needed
  }

  /// Setup automatic cleanup every hour
  void _setupAutoCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupExpired();
    });
  }

  /// Save current state to storage
  Future<void> _saveToStorage() async {
    final data = state.map((item) => DeletedPhotoData(
      id: item.id,
      deletedAt: item.deletedAt,
    )).toList();
    await _storage.saveDeletedItems(data);
  }

  /// Add photo to recently deleted
  Future<void> add(String id, AssetEntity asset) async {
    state = [
      ...state.where((item) => item.id != id),
      DeletedPhoto(
        id: id,
        deletedAt: DateTime.now(),
        asset: asset,
      ),
    ];
    await _saveToStorage();
  }

  /// Add multiple photos
  Future<void> addAll(List<MapEntry<String, AssetEntity>> items) async {
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
    await _saveToStorage();
  }

  /// Remove from recently deleted
  Future<void> remove(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _saveToStorage();
  }

  /// Restore photo (remove from recently deleted)
  Future<void> restore(String id) async {
    await remove(id);
  }

  /// Clear all
  Future<void> clear() async {
    state = [];
    await _storage.clearAll();
  }

  /// Clean up expired items (older than 30 days)
  Future<void> _cleanupExpired() async {
    final oldLength = state.length;
    state = state.where((item) => !item.isExpired).toList();

    // Only save if something changed
    if (state.length != oldLength) {
      await _saveToStorage();
    }
  }

  /// Get count
  int get count => state.length;

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }
}
