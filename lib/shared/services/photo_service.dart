import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

/// Service for accessing and managing photos using PhotoManager
class PhotoService {
  /// Request photo library permission
  Future<PermissionState> requestPermission() async {
    return await PhotoManager.requestPermissionExtend();
  }

  /// Check if permission is granted
  Future<bool> hasPermission() async {
    final state = await PhotoManager.requestPermissionExtend();
    return state.isAuth || state == PermissionState.limited;
  }

  /// Get all albums/asset paths
  Future<List<AssetPathEntity>> getAlbums({
    RequestType type = RequestType.image,
    bool hasAll = true,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: type,
      hasAll: hasAll,
      onlyAll: false,
    );
    return albums;
  }

  /// Get assets from an album with pagination
  Future<List<AssetEntity>> getAssetsFromAlbum(
    AssetPathEntity album, {
    int page = 0,
    int size = 100,
  }) async {
    final assets = await album.getAssetListPaged(
      page: page,
      size: size,
    );
    return assets;
  }

  /// Get all photos with pagination
  Future<List<AssetEntity>> getAllPhotos({
    int page = 0,
    int size = 100,
    RequestType type = RequestType.image,
  }) async {
    final albums = await getAlbums(type: type);
    if (albums.isEmpty) return [];

    final recentAlbum = albums.first; // "Recent" album
    return await getAssetsFromAlbum(recentAlbum, page: page, size: size);
  }

  /// Get photo count
  Future<int> getPhotoCount({RequestType type = RequestType.image}) async {
    final albums = await getAlbums(type: type);
    if (albums.isEmpty) return 0;
    return await albums.first.assetCountAsync;
  }

  /// Delete assets
  Future<List<String>> deleteAssets(List<AssetEntity> assets) async {
    final ids = assets.map((e) => e.id).toList();
    return await PhotoManager.editor.deleteWithIds(ids);
  }

  /// Get file from asset
  Future<String?> getFilePath(AssetEntity asset) async {
    final file = await asset.file;
    return file?.path;
  }

  /// Get thumbnail
  Future<Uint8List?> getThumbnail(
    AssetEntity asset, {
    int width = 200,
    int height = 200,
  }) async {
    return await asset.thumbnailDataWithSize(
      ThumbnailSize(width, height),
    );
  }

  /// Check if asset is screenshot
  bool isScreenshot(AssetEntity asset) {
    // Check if filename contains common screenshot patterns
    final filename = asset.title?.toLowerCase() ?? '';
    return filename.contains('screenshot') ||
        filename.contains('screen_') ||
        filename.startsWith('scr');
  }

  /// Get screenshots from the dedicated album when available.
  ///
  /// This is much more reliable than filename heuristics (especially on iOS).
  Future<List<AssetEntity>> getScreenshots({
    int page = 0,
    int size = 100,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
      onlyAll: false,
    );

    AssetPathEntity? screenshotsAlbum;
    for (final a in albums) {
      final n = a.name.toLowerCase();
      if (n.contains('screenshot') || n.contains('screen capture') || n.contains('screen captures')) {
        screenshotsAlbum = a;
        break;
      }
    }

    if (screenshotsAlbum != null) {
      return await getAssetsFromAlbum(screenshotsAlbum, page: page, size: size);
    }

    // Fallback: filter recents by heuristic.
    final recents = await getAllPhotos(page: page, size: size, type: RequestType.image);
    return recents.where(isScreenshot).toList();
  }

  /// Get creation date
  DateTime? getCreationDate(AssetEntity asset) {
    return asset.createDateTime;
  }

  /// Get file size
  Future<int> getFileSize(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return 0;
    return await file.length();
  }
}
