import 'package:flutter/material.dart';

/// Statistics for home dashboard
class HomeStats {
  final int totalPhotos;
  final int totalVideos;
  final int todayPhotos;
  final int deleteQueueCount;
  final int storageUsed; // in bytes
  final int storageFreeable; // in bytes

  const HomeStats({
    required this.totalPhotos,
    required this.totalVideos,
    required this.todayPhotos,
    required this.deleteQueueCount,
    required this.storageUsed,
    required this.storageFreeable,
  });

  String get formattedStorageUsed {
    return _formatBytes(storageUsed);
  }

  String get formattedStorageFreeable {
    return _formatBytes(storageFreeable);
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
  }
}

/// Quick action item
class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
