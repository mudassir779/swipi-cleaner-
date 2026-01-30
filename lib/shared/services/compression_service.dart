import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// Result of a compression operation
class CompressionResult {
  final File compressedFile;
  final int originalSize;
  final int compressedSize;
  final double savingsPercent;

  CompressionResult({
    required this.compressedFile,
    required this.originalSize,
    required this.compressedSize,
  }) : savingsPercent = originalSize > 0
            ? ((originalSize - compressedSize) / originalSize * 100)
            : 0;

  int get savedBytes => originalSize - compressedSize;
}

/// Service for compressing photos
class CompressionService {
  /// Compress a single image file
  /// [quality] ranges from 1-100 (lower = more compression)
  /// [maxWidth] and [maxHeight] for resizing (optional)
  Future<CompressionResult?> compressImage({
    required File file,
    int quality = 70,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final originalSize = await file.length();
      final bytes = await file.readAsBytes();

      // Decode image
      final image = await compute(_decodeImage, bytes);
      if (image == null) return null;

      // Resize if needed
      img.Image processedImage = image;
      if (maxWidth != null || maxHeight != null) {
        processedImage = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          maintainAspect: true,
        );
      }

      // Encode as JPEG with quality
      final compressedBytes = img.encodeJpg(processedImage, quality: quality);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedFile = File('${tempDir.path}/compressed_$timestamp.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return CompressionResult(
        compressedFile: compressedFile,
        originalSize: originalSize,
        compressedSize: compressedBytes.length,
      );
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Compress an AssetEntity (photo from gallery)
  Future<CompressionResult?> compressAsset({
    required AssetEntity asset,
    int quality = 70,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final file = await asset.file;
    if (file == null) return null;

    return compressImage(
      file: file,
      quality: quality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Batch compress multiple assets
  /// Returns a stream of results for progress tracking
  Stream<CompressionResult> compressMultiple({
    required List<AssetEntity> assets,
    int quality = 70,
    int? maxWidth,
    int? maxHeight,
  }) async* {
    for (final asset in assets) {
      final result = await compressAsset(
        asset: asset,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (result != null) {
        yield result;
      }
    }
  }

  /// Estimate compressed size without actually compressing
  Future<int> estimateCompressedSize({
    required int originalSize,
    int quality = 70,
  }) async {
    // Rough estimation based on quality
    // This is approximate; actual results vary by image content
    final ratio = quality / 100;
    final estimatedRatio = 0.1 + (ratio * 0.5); // 10-60% of original
    return (originalSize * estimatedRatio).round();
  }

  /// Get quality preset name
  static String getQualityPresetName(int quality) {
    if (quality >= 90) return 'High Quality';
    if (quality >= 70) return 'Balanced';
    if (quality >= 50) return 'Medium';
    return 'Maximum Compression';
  }

  /// Save compressed image to gallery
  Future<AssetEntity?> saveToGallery(File compressedFile) async {
    try {
      final bytes = await compressedFile.readAsBytes();
      final result = await PhotoManager.editor.saveImage(
        bytes,
        filename: 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      return result;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return null;
    }
  }
}

/// Decode image in isolate for better performance
img.Image? _decodeImage(Uint8List bytes) {
  return img.decodeImage(bytes);
}
