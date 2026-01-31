import 'package:photo_manager/photo_manager.dart';

/// Photo model representing a single photo/image asset
class Photo {
  final String id;
  final String? title;
  final DateTime creationDate;
  final int width;
  final int height;
  final int? fileSize;
  final AssetEntity asset;

  const Photo({
    required this.id,
    this.title,
    required this.creationDate,
    required this.width,
    required this.height,
    this.fileSize,
    required this.asset,
  });

  /// Fast creation without file size (for lists - much faster)
  static Photo fromAssetSync(AssetEntity asset) {
    return Photo(
      id: asset.id,
      title: asset.title,
      creationDate: asset.createDateTime,
      width: asset.width,
      height: asset.height,
      fileSize: null,
      asset: asset,
    );
  }

  /// Full creation with file size (for details screen only)
  static Future<Photo> fromAsset(AssetEntity asset) async {
    final file = await asset.file;
    final fileSize = file != null ? await file.length() : null;

    return Photo(
      id: asset.id,
      title: asset.title,
      creationDate: asset.createDateTime,
      width: asset.width,
      height: asset.height,
      fileSize: fileSize,
      asset: asset,
    );
  }

  /// Get formatted file size
  String get formattedSize {
    final size = fileSize ?? estimatedSize;
    if (size == 0) return 'Unknown';
    final sizeInMB = size / (1024 * 1024);
    if (sizeInMB >= 1) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
    final sizeInKB = size / 1024;
    return '${sizeInKB.toStringAsFixed(0)} KB';
  }

  /// Estimate file size from dimensions when actual size isn't loaded
  /// Uses ~3 bytes per pixel (RGB) with typical JPEG compression ratio of 10:1
  int get estimatedSize {
    if (fileSize != null) return fileSize!;
    // Estimate: width * height * 3 bytes RGB / 10 compression ratio
    return (width * height * 3) ~/ 10;
  }

  /// Check if photo is large (>10MB)
  bool get isLarge {
    final size = fileSize ?? estimatedSize;
    return size > 10 * 1024 * 1024;
  }

  /// Check if photo is old (>1 year)
  bool get isOld {
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    return creationDate.isBefore(oneYearAgo);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
