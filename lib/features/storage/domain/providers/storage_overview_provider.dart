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

  // Estimate freeable from the current delete queue
  final deleteQueue = ref.read(deleteQueueProvider);
  int freeableBytes = 0;
  for (final id in deleteQueue) {
    final asset = await AssetEntity.fromId(id);
    if (asset == null) continue;
    freeableBytes += await photoService.getFileSize(asset);
  }

  // Get all photos and videos to calculate ACTUAL sizes
  final allPhotos = await photoService.getAllPhotos(page: 0, size: 500, type: RequestType.image);
  final allVideos = await photoService.getAllPhotos(page: 0, size: 200, type: RequestType.video);

  // Calculate actual bytes for photos
  int photosBytes = 0;
  int screenshotsBytes = 0;
  int screenshotCount = 0;
  
  for (final photo in allPhotos) {
    final size = await photoService.getFileSize(photo);
    if (photoService.isScreenshot(photo)) {
      screenshotsBytes += size;
      screenshotCount++;
    } else {
      photosBytes += size;
    }
  }

  // Calculate actual bytes for videos
  int videosBytes = 0;
  for (final video in allVideos) {
    final size = await photoService.getFileSize(video);
    videosBytes += size;
  }

  final photoCount = allPhotos.length - screenshotCount;
  final videoCount = allVideos.length;

  // Total media usage
  final totalMediaBytes = photosBytes + videosBytes + screenshotsBytes;

  // Check permission state for UI
  final permState = await PhotoManager.requestPermissionExtend();
  final isLimited = permState == PermissionState.limited;
  final statusSuffix = isLimited ? ' (Limited)' : '';

  // Build categories - ONLY media, no "Apps & Other"
  final categories = <StorageCategory>[];
  
  if (photosBytes > 0 || photoCount > 0) {
    categories.add(StorageCategory(
      name: 'Photos$statusSuffix ($photoCount)',
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

