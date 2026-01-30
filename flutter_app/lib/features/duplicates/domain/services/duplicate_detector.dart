import 'dart:isolate';
// ignore: unused_import
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';
import '../../../photos/domain/models/photo.dart';
import '../models/duplicate_group.dart';

/// Service for detecting duplicate and similar photos using perceptual hashing
class DuplicateDetector {
  /// Find duplicate groups in a list of photos
  /// Uses isolate for background processing to avoid UI jank
  Future<List<DuplicateGroup>> findDuplicates(
    List<Photo> photos, {
    int similarityThreshold = 10,
    Function(int current, int total)? onProgress,
  }) async {
    if (photos.isEmpty) return [];

    // For small lists, process directly
    if (photos.length < 50) {
      return _findDuplicatesSync(photos, similarityThreshold, onProgress);
    }

    // For larger lists, use isolate for background processing
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _isolateFindDuplicates,
      _IsolateParams(
        photos: photos,
        similarityThreshold: similarityThreshold,
        sendPort: receivePort.sendPort,
      ),
    );

    final result = await receivePort.first as List<DuplicateGroup>;
    return result;
  }

  /// Synchronous duplicate finding (used for small lists or in isolate)
  Future<List<DuplicateGroup>> _findDuplicatesSync(
    List<Photo> photos,
    int similarityThreshold,
    Function(int current, int total)? onProgress,
  ) async {
    final List<DuplicateGroup> groups = [];
    final Map<String, String> photoHashes = {};
    final processed = <String>{};

    // Compute perceptual hashes for all photos
    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      try {
        photoHashes[photo.id] = await _computePerceptualHash(photo);
        onProgress?.call(i + 1, photos.length);
      } catch (e) {
        // Skip photos that can't be processed
        debugPrint('Error processing photo ${photo.id}: $e');
        continue;
      }
    }

    // Find similar photos
    for (final photo in photos) {
      if (processed.contains(photo.id)) continue;
      if (!photoHashes.containsKey(photo.id)) continue;

      final similar = <Photo>[photo];
      final similarities = <double>[];

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
          // Calculate similarity percentage (0-100%)
          similarities.add(100.0 - (distance / 64.0 * 100.0));
        }
      }

      if (similar.length > 1) {
        // Use average similarity score
        final avgSimilarity = similarities.isEmpty
            ? 100.0
            : similarities.reduce((a, b) => a + b) / similarities.length;

        groups.add(DuplicateGroup(
          photos: similar,
          similarityScore: avgSimilarity / 100.0,
        ));
        processed.addAll(similar.map((p) => p.id));
      }
    }

    // Sort groups by similarity (highest first)
    groups.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

    return groups;
  }

  /// Compute perceptual hash using difference hash (dHash) algorithm
  /// This is more robust than simple average hash and works well for finding duplicates
  Future<String> _computePerceptualHash(Photo photo) async {
    try {
      // Get thumbnail bytes (32x32 is good balance of accuracy vs speed)
      final bytes = await photo.asset.thumbnailDataWithSize(
        const ThumbnailSize(32, 32),
      );

      if (bytes == null) {
        throw Exception('Failed to get thumbnail');
      }

      // Decode image using image package
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Convert to grayscale
      final grayscale = img.grayscale(image);

      // Resize to 9x8 for difference hash (we need 9 width to compare 8 adjacent pixels)
      final resized = img.copyResize(grayscale, width: 9, height: 8);

      // Compute difference hash
      // Compare each pixel to its neighbor on the right
      final buffer = StringBuffer();
      for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
          final pixel = resized.getPixel(x, y);
          final nextPixel = resized.getPixel(x + 1, y);

          // Get luminance (red channel in grayscale)
          final luminance = pixel.r.toInt();
          final nextLuminance = nextPixel.r.toInt();

          // 1 if current pixel is brighter than next, 0 otherwise
          buffer.write(luminance > nextLuminance ? '1' : '0');
        }
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Error computing perceptual hash: $e');
      rethrow;
    }
  }

  /// Calculate Hamming distance between two hash strings
  /// This measures how many bits differ between the two hashes
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

  /// Isolate entry point for background duplicate detection
  static void _isolateFindDuplicates(_IsolateParams params) async {
    final detector = DuplicateDetector();
    final result = await detector._findDuplicatesSync(
      params.photos,
      params.similarityThreshold,
      null, // No progress callback in isolate
    );
    params.sendPort.send(result);
  }
}

/// Parameters for isolate-based duplicate detection
class _IsolateParams {
  final List<Photo> photos;
  final int similarityThreshold;
  final SendPort sendPort;

  _IsolateParams({
    required this.photos,
    required this.similarityThreshold,
    required this.sendPort,
  });
}
