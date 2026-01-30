import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/photo_service.dart';
import '../../../home/domain/providers/home_provider.dart';
import '../models/storage_category.dart';
import '../models/storage_overview.dart';

final storageOverviewProvider = FutureProvider<StorageOverview>((ref) async {
  final photoService = PhotoService();
  final hasPermission = await photoService.hasPermission();

  if (!hasPermission) {
    return const StorageOverview(
      estimatedUsedBytes: 0,
      estimatedCapacityBytes: 0,
      estimatedFreeableBytes: 0,
      categories: [],
    );
  }

  final homeStats = await ref.watch(homeStatsProvider.future);
  final usedBytes = homeStats.storageUsed;
  final freeableBytes = homeStats.storageFreeable;

  final photoCount = await photoService.getPhotoCount(type: RequestType.image);
  final videoCount = await photoService.getPhotoCount(type: RequestType.video);

  // Estimate average sizes using a small sample (keeps it fast).
  final sampleImages = await photoService.getAllPhotos(page: 0, size: 40, type: RequestType.image);
  final sampleVideos = await photoService.getAllPhotos(page: 0, size: 20, type: RequestType.video);

  int imgBytesTotal = 0;
  for (final a in sampleImages) {
    imgBytesTotal += await photoService.getFileSize(a);
  }
  int vidBytesTotal = 0;
  for (final v in sampleVideos) {
    vidBytesTotal += await photoService.getFileSize(v);
  }

  final avgImg = sampleImages.isEmpty ? 0 : (imgBytesTotal ~/ sampleImages.length);
  final avgVid = sampleVideos.isEmpty ? 0 : (vidBytesTotal ~/ sampleVideos.length);

  final estimatedPhotosBytes = avgImg * photoCount;
  final estimatedVideosBytes = avgVid * videoCount;

  // Rough screenshots estimate from sample ratio
  int screenshotSampleCount = 0;
  for (final a in sampleImages) {
    if (photoService.isScreenshot(a)) screenshotSampleCount += 1;
  }
  final screenshotRatio = sampleImages.isEmpty ? 0.0 : (screenshotSampleCount / sampleImages.length);
  final estimatedScreenshotsBytes = (estimatedPhotosBytes * screenshotRatio).round();
  final estimatedPhotosNoScreenshotsBytes =
      (estimatedPhotosBytes - estimatedScreenshotsBytes).clamp(0, estimatedPhotosBytes);

  // Capacity isn't available from our current services; show a conservative “used + headroom” estimate.
  final estimatedCapacityBytes = usedBytes == 0 ? 0 : (usedBytes * 1.45).round();

  final otherBytes = (usedBytes - estimatedPhotosBytes - estimatedVideosBytes).clamp(0, usedBytes);

  return StorageOverview(
    estimatedUsedBytes: usedBytes,
    estimatedCapacityBytes: estimatedCapacityBytes,
    estimatedFreeableBytes: freeableBytes,
    categories: [
      StorageCategory(
        name: 'Photos',
        icon: Icons.photo_camera_rounded,
        color: AppColors.primary, // SkyBlue
        bytes: estimatedPhotosNoScreenshotsBytes,
      ),
      StorageCategory(
        name: 'Videos',
        icon: Icons.videocam_rounded,
        color: const Color(0xFF3B82F6), // Blue
        bytes: estimatedVideosBytes,
      ),
      StorageCategory(
        name: 'Screenshots',
        icon: Icons.image_rounded,
        color: const Color(0xFF06B6D4), // Cyan
        bytes: estimatedScreenshotsBytes,
      ),
      StorageCategory(
        name: 'Other',
        icon: Icons.folder_rounded,
        color: const Color(0xFF64748B), // Slate
        bytes: otherBytes,
      ),
    ],
  );
});

