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
    if (fileSize == null) return 'Unknown';
    final sizeInMB = fileSize! / (1024 * 1024);
    if (sizeInMB >= 1) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
    final sizeInKB = fileSize! / 1024;
    return '${sizeInKB.toStringAsFixed(0)} KB';
  }

  /// Check if photo is large (>10MB)
  bool get isLarge {
    return fileSize != null && fileSize! > 10 * 1024 * 1024;
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
