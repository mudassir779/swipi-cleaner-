import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/device_storage_service.dart';
import '../../../../shared/services/photo_service.dart';
import '../../../photos/domain/providers/delete_queue_provider.dart';
import '../models/storage_category.dart';
import '../models/storage_overview.dart';

final storageOverviewProvider = FutureProvider<StorageOverview>((ref) async {
  final deviceStorageService = DeviceStorageService();
  final photoService = PhotoService();
  final storageInfo = await deviceStorageService.getStorageInfo();
  final capacityBytes = storageInfo.totalBytes;

  final hasPhotosPermission = await photoService.hasPermission();
  if (!hasPhotosPermission) {
    return StorageOverview(
      estimatedUsedBytes: 0,
      estimatedCapacityBytes: capacityBytes,
      estimatedFreeableBytes: 0,
      categories: [
        StorageCategory(
          name: 'No Permission',
          icon: Icons.lock_rounded,
          color: const Color(0xFF64748B),
          bytes: 0,
        ),
      ],
    );
  }

  // Estimate freeable from the current delete queue (small list, OK to iterate)
  final deleteQueue = ref.read(deleteQueueProvider);
  int freeableBytes = 0;
  for (final id in deleteQueue) {
    final asset = await AssetEntity.fromId(id);
    if (asset == null) continue;
    freeableBytes += await photoService.getFileSize(asset);
  }

  // Use FAST native API counts instead of loading all photos
  final photoCount = await photoService.getPhotoCount(type: RequestType.image);
  final videoCount = await photoService.getPhotoCount(type: RequestType.video);
  
  // Get screenshot count from dedicated album (fast)
  int screenshotCount = 0;
  
  // Quick sample to estimate screenshots - get screenshot album count if available
  final albums = await PhotoManager.getAssetPathList(type: RequestType.image, hasAll: false);
  for (final album in albums) {
    final name = album.name.toLowerCase();
    if (name.contains('screenshot') || name.contains('screen capture')) {
      screenshotCount = await album.assetCountAsync;
      break;
    }
  }
  
  // Estimate sizes using average file sizes (much faster than reading each file)
  // Average photo: ~3MB, Average video: ~50MB, Average screenshot: ~500KB
  const avgPhotoBytes = 3 * 1024 * 1024;      // 3 MB
  const avgVideoBytes = 50 * 1024 * 1024;     // 50 MB  
  const avgScreenshotBytes = 500 * 1024;      // 500 KB
  
  final photosBytes = (photoCount - screenshotCount).clamp(0, photoCount) * avgPhotoBytes;
  final videosBytes = videoCount * avgVideoBytes;
  final screenshotsBytes = screenshotCount * avgScreenshotBytes;
  
  // Total media usage
  final totalMediaBytes = photosBytes + videosBytes + screenshotsBytes;

  // Check permission state for UI
  final permState = await PhotoManager.requestPermissionExtend();
  final isLimited = permState == PermissionState.limited;
  final statusSuffix = isLimited ? ' (Limited)' : '';

  // Build categories - ONLY media, no "Apps & Other"
  final categories = <StorageCategory>[];
  
  final actualPhotoCount = (photoCount - screenshotCount).clamp(0, photoCount);
  if (photosBytes > 0 || actualPhotoCount > 0) {
    categories.add(StorageCategory(
      name: 'Photos$statusSuffix ($actualPhotoCount)',
      icon: Icons.photo_camera_rounded,
      color: AppColors.primary,
      bytes: photosBytes,
    ));
  }
  
  if (videosBytes > 0 || videoCount > 0) {
    categories.add(StorageCategory(
      name: 'Videos$statusSuffix ($videoCount)',
      icon: Icons.videocam_rounded,
      color: const Color(0xFF3B82F6),
      bytes: videosBytes,
    ));
  }
  
  if (screenshotsBytes > 0 || screenshotCount > 0) {
    categories.add(StorageCategory(
      name: 'Screenshots ($screenshotCount)',
      icon: Icons.image_rounded,
      color: const Color(0xFF06B6D4),
      bytes: screenshotsBytes,
    ));
  }

  // If no media at all, show empty state
  if (categories.isEmpty) {
    categories.add(StorageCategory(
      name: 'No Media Found',
      icon: Icons.photo_library_outlined,
      color: const Color(0xFF94A3B8),
      bytes: 0,
    ));
  }

  return StorageOverview(
    estimatedUsedBytes: totalMediaBytes,
    estimatedCapacityBytes: capacityBytes,
    estimatedFreeableBytes: freeableBytes,
    categories: categories,
  );
});

