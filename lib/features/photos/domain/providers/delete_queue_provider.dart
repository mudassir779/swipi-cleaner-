import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing the delete queue
final deleteQueueProvider =
    StateNotifierProvider<DeleteQueueNotifier, Set<String>>((ref) {
  return DeleteQueueNotifier();
});

class DeleteQueueNotifier extends StateNotifier<Set<String>> {
  DeleteQueueNotifier() : super({});

  /// Add photo to delete queue
  void add(String photoId) {
    state = {...state, photoId};
  }

  /// Remove photo from delete queue
  void remove(String photoId) {
    state = state.where((id) => id != photoId).toSet();
  }

  /// Toggle photo in delete queue
  void toggle(String photoId) {
    if (state.contains(photoId)) {
      remove(photoId);
    } else {
      add(photoId);
    }
  }

  /// Check if photo is in queue
  bool contains(String photoId) {
    return state.contains(photoId);
  }

  /// Add multiple photos
  void addAll(List<String> photoIds) {
    state = {...state, ...photoIds};
  }

  /// Select all photos
  void selectAll(List<String> photoIds) {
    state = photoIds.toSet();
  }

  /// Deselect all photos
  void deselectAll() {
    state = {};
  }

  /// Invert selection
  void invertSelection(List<String> allPhotoIds) {
    final currentIds = state;
    final newIds = allPhotoIds.where((id) => !currentIds.contains(id)).toSet();
    state = newIds;
  }

  /// Clear queue
  void clear() {
    state = {};
  }

  /// Get count
  int get count => state.length;

  /// Check if empty
  bool get isEmpty => state.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => state.isNotEmpty;
}
