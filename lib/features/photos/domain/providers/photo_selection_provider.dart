import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoSelectionProvider =
    StateNotifierProvider<PhotoSelectionNotifier, PhotoSelectionState>((ref) {
  return PhotoSelectionNotifier();
});

class PhotoSelectionState {
  final bool isSelectionMode;
  final Set<String> selectedIds;

  const PhotoSelectionState({
    required this.isSelectionMode,
    required this.selectedIds,
  });

  int get count => selectedIds.length;
}

class PhotoSelectionNotifier extends StateNotifier<PhotoSelectionState> {
  PhotoSelectionNotifier()
      : super(const PhotoSelectionState(isSelectionMode: false, selectedIds: {}));

  void enterSelectionMode({String? initialId}) {
    state = PhotoSelectionState(
      isSelectionMode: true,
      selectedIds: initialId == null ? state.selectedIds : {...state.selectedIds, initialId},
    );
  }

  void exitSelectionMode() {
    state = const PhotoSelectionState(isSelectionMode: false, selectedIds: {});
  }

  void toggle(String id) {
    final next = Set<String>.from(state.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = PhotoSelectionState(isSelectionMode: true, selectedIds: next);
    if (state.selectedIds.isEmpty) {
      exitSelectionMode();
    }
  }

  void selectAll(Iterable<String> ids) {
    state = PhotoSelectionState(isSelectionMode: true, selectedIds: ids.toSet());
  }

  void clear() {
    exitSelectionMode();
  }
}

