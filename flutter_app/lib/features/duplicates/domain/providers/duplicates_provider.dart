import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../photos/domain/providers/photo_provider.dart';
import '../models/duplicate_group.dart';
import '../services/duplicate_detector.dart';

/// Provider for duplicate photo groups
final duplicatesProvider = FutureProvider<List<DuplicateGroup>>((ref) async {
  final photos = await ref.watch(photosProvider(0).future);
  final detector = DuplicateDetector();
  return await detector.findDuplicates(photos);
});

/// Provider for managing selected photos for deletion in duplicates screen
final duplicateSelectionProvider =
    StateNotifierProvider<DuplicateSelectionNotifier, Set<String>>((ref) {
  return DuplicateSelectionNotifier();
});

/// State notifier for managing duplicate photo selection
class DuplicateSelectionNotifier extends StateNotifier<Set<String>> {
  DuplicateSelectionNotifier() : super({});

  /// Toggle selection for a photo
  void toggle(String id) {
    if (state.contains(id)) {
      state = Set.from(state)..remove(id);
    } else {
      state = Set.from(state)..add(id);
    }
  }

  /// Add multiple photo IDs to selection
  void addAll(Set<String> ids) {
    state = Set.from(state)..addAll(ids);
  }

  /// Clear all selections
  void clear() {
    state = {};
  }

  /// Remove a photo ID from selection
  void remove(String id) {
    state = Set.from(state)..remove(id);
  }
}
