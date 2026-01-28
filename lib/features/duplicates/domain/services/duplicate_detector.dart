import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '../../../photos/domain/models/photo.dart';
import '../models/duplicate_group.dart';

/// Service for detecting duplicate and similar photos
class DuplicateDetector {
  /// Threshold for considering photos as duplicates (0-64, lower = more similar)
  static const int similarityThreshold = 10;

  /// Find duplicate groups in a list of photos
  Future<List<DuplicateGroup>> findDuplicates(List<Photo> photos) async {
    final List<DuplicateGroup> groups = [];
    final Map<String, String> photoHashes = {};
    final processed = <String>{};

    // Compute hashes for all photos
    for (final photo in photos) {
      try {
        photoHashes[photo.id] = await _computeSimpleHash(photo);
      } catch (e) {
        // Skip photos that can't be processed
        continue;
      }
    }

    // Find similar photos
    for (final photo in photos) {
      if (processed.contains(photo.id)) continue;
      if (!photoHashes.containsKey(photo.id)) continue;

      final similar = <Photo>[photo];

      for (final other in photos) {
        if (processed.contains(other.id) || photo.id == other.id) continue;
        if (!photoHashes.containsKey(other.id)) continue;

        final distance = _hammingDistance(
          photoHashes[photo.id]!,
          photoHashes[other.id]!,
        );

        if (distance <= similarityThreshold) {
          similar.add(other);
          processed.add(other.id);
        }
      }

      if (similar.length > 1) {
        groups.add(DuplicateGroup(
          photos: similar,
          similarityScore: 1.0 - (similarityThreshold / 64.0),
        ));
        processed.addAll(similar.map((p) => p.id));
      }
    }

    return groups;
  }

  /// Compute a simple hash for a photo based on dimensions and file size
  /// NOTE: For production, use perceptual hashing (pHash) or difference hashing (dHash)
  /// which analyze actual image content, not just metadata
  Future<String> _computeSimpleHash(Photo photo) async {
    // Create a simple hash based on dimensions and file size
    // This will catch exact duplicates but not visually similar images
    final width = photo.width;
    final height = photo.height;
    final size = photo.fileSize ?? 0;

    // For better duplicate detection, we should:
    // 1. Get thumbnail bytes: await photo.asset.thumbnailDataWithSize(ThumbnailSize(32, 32))
    // 2. Convert to grayscale
    // 3. Resize to 8x8 or 32x32
    // 4. Compute DCT (Discrete Cosine Transform) for pHash
    // 5. Or compute average hash for simpler approach

    // Simple approach: create hash from metadata
    final buffer = StringBuffer();
    buffer.write(width.toString().padLeft(5, '0'));
    buffer.write(height.toString().padLeft(5, '0'));
    buffer.write((size ~/ 1024).toString().padLeft(8, '0')); // KB

    // Try to get a basic image fingerprint
    try {
      final bytes = await photo.asset.thumbnailDataWithSize(
        ThumbnailSize(8, 8),
      );
      if (bytes != null) {
        // Compute simple average hash
        buffer.write(_computeAverageHash(bytes));
      }
    } catch (e) {
      // If thumbnail fails, just use metadata hash
    }

    return buffer.toString();
  }

  /// Compute average hash from image bytes (simplified version)
  String _computeAverageHash(Uint8List bytes) {
    // This is a simplified version. For production:
    // 1. Decode image properly
    // 2. Convert to grayscale
    // 3. Resize to 8x8
    // 4. Compute average pixel value
    // 5. Create binary hash (1 if pixel > average, 0 otherwise)

    // For now, just sample some bytes to create a hash
    final buffer = StringBuffer();
    final step = bytes.length ~/ 64;

    for (int i = 0; i < 64 && i * step < bytes.length; i++) {
      buffer.write((bytes[i * step] > 128) ? '1' : '0');
    }

    return buffer.toString().padRight(64, '0');
  }

  /// Calculate Hamming distance between two hash strings
  int _hammingDistance(String hash1, String hash2) {
    if (hash1.length != hash2.length) {
      return 64; // Maximum distance
    }

    int distance = 0;
    for (int i = 0; i < hash1.length; i++) {
      if (hash1[i] != hash2[i]) distance++;
    }
    return distance;
  }
}
