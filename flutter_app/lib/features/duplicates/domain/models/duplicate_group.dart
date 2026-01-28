import '../../../photos/domain/models/photo.dart';

/// Group of duplicate/similar photos
class DuplicateGroup {
  final List<Photo> photos;
  final double similarityScore;

  const DuplicateGroup({
    required this.photos,
    this.similarityScore = 0.0,
  });

  /// Number of photos in this group
  int get photoCount => photos.length;

  /// Get the best quality photo (largest file size)
  Photo get bestPhoto {
    return photos.reduce((a, b) =>
      (a.fileSize ?? 0) > (b.fileSize ?? 0) ? a : b
    );
  }

  /// Get all photos except the best one
  List<Photo> get duplicates {
    final best = bestPhoto;
    return photos.where((p) => p.id != best.id).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuplicateGroup &&
          runtimeType == other.runtimeType &&
          photos == other.photos;

  @override
  int get hashCode => photos.hashCode;
}
