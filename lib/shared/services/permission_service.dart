import 'package:permission_handler/permission_handler.dart';

/// Service for handling photo library permissions
class PermissionService {
  /// Check if photo library permission is granted
  Future<bool> hasPhotoPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  /// Request photo library permission
  Future<PermissionStatus> requestPhotoPermission() async {
    return await Permission.photos.request();
  }

  /// Check permission status
  Future<PermissionStatus> getPhotoPermissionStatus() async {
    return await Permission.photos.status;
  }

  // /// Open app settings
  // /// Commented out due to API compatibility issues with permission_handler
  // Future<bool> openSettings() async {
  //   return await openAppSettings();
  // }
}
