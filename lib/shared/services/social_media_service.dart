import 'dart:io';
import 'package:flutter/foundation.dart';

/// Types of social media apps supported
enum SocialMediaApp {
  whatsapp,
  telegram,
}

/// Represents a media file from social media apps
class SocialMediaFile {
  final File file;
  final String name;
  final int size;
  final DateTime modified;
  final SocialMediaFileType type;

  SocialMediaFile({
    required this.file,
    required this.name,
    required this.size,
    required this.modified,
    required this.type,
  });
}

enum SocialMediaFileType {
  image,
  video,
  audio,
  document,
  other,
}

/// Service for scanning and cleaning social media files
class SocialMediaService {
  // Known paths for WhatsApp on Android
  static const List<String> _whatsAppPaths = [
    '/storage/emulated/0/WhatsApp/Media',
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media',
    '/sdcard/WhatsApp/Media',
  ];

  // Known paths for Telegram on Android
  static const List<String> _telegramPaths = [
    '/storage/emulated/0/Telegram',
    '/storage/emulated/0/Android/data/org.telegram.messenger/files/Telegram',
    '/sdcard/Telegram',
  ];

  /// Get all media files from WhatsApp
  Future<List<SocialMediaFile>> getWhatsAppFiles() async {
    return _scanSocialMediaPaths(_whatsAppPaths, SocialMediaApp.whatsapp);
  }

  /// Get all media files from Telegram
  Future<List<SocialMediaFile>> getTelegramFiles() async {
    return _scanSocialMediaPaths(_telegramPaths, SocialMediaApp.telegram);
  }

  /// Scan paths for media files
  Future<List<SocialMediaFile>> _scanSocialMediaPaths(
    List<String> paths,
    SocialMediaApp app,
  ) async {
    List<SocialMediaFile> allFiles = [];

    for (final basePath in paths) {
      final baseDir = Directory(basePath);
      if (!await baseDir.exists()) continue;

      try {
        await for (final entity in baseDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              final stat = await entity.stat();
              final name = entity.path.split('/').last;
              final type = _getFileType(name);

              // Skip non-media files
              if (type == SocialMediaFileType.other) continue;

              allFiles.add(SocialMediaFile(
                file: entity,
                name: name,
                size: stat.size,
                modified: stat.modified,
                type: type,
              ));
            } catch (e) {
              debugPrint('Error reading file stats: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error scanning directory $basePath: $e');
      }
    }

    // Sort by size (largest first)
    allFiles.sort((a, b) => b.size.compareTo(a.size));

    return allFiles;
  }

  /// Determine file type from extension
  SocialMediaFileType _getFileType(String filename) {
    final ext = filename.toLowerCase().split('.').last;

    // Images
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'].contains(ext)) {
      return SocialMediaFileType.image;
    }

    // Videos
    if (['mp4', 'mov', 'avi', 'mkv', '3gp', 'webm'].contains(ext)) {
      return SocialMediaFileType.video;
    }

    // Audio
    if (['mp3', 'ogg', 'opus', 'wav', 'm4a', 'aac'].contains(ext)) {
      return SocialMediaFileType.audio;
    }

    // Documents
    if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(ext)) {
      return SocialMediaFileType.document;
    }

    return SocialMediaFileType.other;
  }

  /// Delete a list of files
  Future<int> deleteFiles(List<SocialMediaFile> files) async {
    int deletedCount = 0;

    for (final file in files) {
      try {
        if (await file.file.exists()) {
          await file.file.delete();
          deletedCount++;
        }
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
    }

    return deletedCount;
  }

  /// Get total size of files
  int getTotalSize(List<SocialMediaFile> files) {
    return files.fold(0, (sum, file) => sum + file.size);
  }

  /// Filter files by type
  List<SocialMediaFile> filterByType(
    List<SocialMediaFile> files,
    SocialMediaFileType type,
  ) {
    return files.where((f) => f.type == type).toList();
  }

  /// Check if running on iOS (limited access to social media folders)
  bool get isIOS => Platform.isIOS;

  /// Check if social media cleanup is supported on this platform
  Future<bool> isSupported() async {
    if (Platform.isIOS) {
      // iOS doesn't allow access to other app's folders
      return false;
    }

    if (Platform.isAndroid) {
      // Check if any WhatsApp or Telegram folder exists
      for (final path in [..._whatsAppPaths, ..._telegramPaths]) {
        if (await Directory(path).exists()) {
          return true;
        }
      }
    }

    return false;
  }
}
