import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../photos/domain/providers/photo_provider.dart';
import '../models/duplicate_group.dart';
import '../services/duplicate_detector.dart';

/// Provider for similarity threshold (0-30, default 10)
/// Lower = stricter matching (only near-identical)
/// Higher = looser matching (visually similar)
final similarityThresholdProvider = StateProvider<int>((ref) => 10);

/// Provider for scan progress (current/total)
final scanProgressProvider = StateProvider<Map<String, int>>((ref) => {
      'current': 0,
      'total': 0,
    });

/// Provider for duplicate photo groups
/// Automatically re-scans when similarity threshold changes
final duplicatesProvider = FutureProvider<List<DuplicateGroup>>((ref) async {
  final photos = await ref.watch(photosProvider(0).future);
  final threshold = ref.watch(similarityThresholdProvider);

  // Reset progress
  ref.read(scanProgressProvider.notifier).state = {
    'current': 0,
    'total': photos.length,
  };

  final detector = DuplicateDetector();
  return await detector.findDuplicates(
    photos,
    similarityThreshold: threshold,
    onProgress: (current, total) {
      // Update progress
      ref.read(scanProgressProvider.notifier).state = {
        'current': current,
        'total': total,
      };
    },
  );
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

  /// Smart select - select all photos except the one with highest quality in each group
  void smartSelectFrom(List<DuplicateGroup> groups) {
    state = {};
    for (final group in groups) {
      // Sort by file size (highest quality = largest file usually)
      final sorted = List<String>.from(group.photos.map((p) => p.id));
      // Keep first photo (reference), select others for deletion
      if (sorted.length > 1) {
        state = Set.from(state)..addAll(sorted.skip(1));
      }
    }
  }
}
