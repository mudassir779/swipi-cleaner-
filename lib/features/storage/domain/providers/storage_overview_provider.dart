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

  final hasPhotosPermission = await photoService.hasPermission();
  if (!hasPhotosPermission) {
    final used = storageInfo.usedBytes;
    final cap = storageInfo.totalBytes;
    return StorageOverview(
      estimatedUsedBytes: used,
      estimatedCapacityBytes: cap,
      estimatedFreeableBytes: 0,
      categories: [
        StorageCategory(
          name: 'Other',
          icon: Icons.folder_rounded,
          color: const Color(0xFF64748B),
          bytes: used,
        ),
      ],
    );
  }

  final usedBytes = storageInfo.usedBytes;
  final capacityBytes = storageInfo.totalBytes;

  // Estimate freeable from the current delete queue (accurate for queued items).
  final deleteQueue = ref.read(deleteQueueProvider);
  int freeableBytes = 0;
  for (final id in deleteQueue) {
    final asset = await AssetEntity.fromId(id);
    if (asset == null) continue;
    freeableBytes += await photoService.getFileSize(asset);
  }

  final photoCount = await photoService.getPhotoCount(type: RequestType.image);
  final videoCount = await photoService.getPhotoCount(type: RequestType.video);

  // Estimate average sizes using a small sample (keeps it fast).
  final sampleImages = <AssetEntity>[
    ...await photoService.getAllPhotos(page: 0, size: 40, type: RequestType.image),
    ...await photoService.getAllPhotos(page: 1, size: 40, type: RequestType.image),
    ...await photoService.getAllPhotos(page: 2, size: 40, type: RequestType.image),
  ];
  final sampleVideos = <AssetEntity>[
    ...await photoService.getAllPhotos(page: 0, size: 20, type: RequestType.video),
    ...await photoService.getAllPhotos(page: 1, size: 20, type: RequestType.video),
  ];

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

  // Make breakdown sum to device used storage.
  int photosBytes = estimatedPhotosNoScreenshotsBytes;
  int videosBytes = estimatedVideosBytes;
  int screenshotsBytes = estimatedScreenshotsBytes;

  final mediaTotal = photosBytes + videosBytes + screenshotsBytes;
  int otherBytes;
  if (usedBytes > 0 && mediaTotal > usedBytes) {
    // Rare but possible when sampling overestimates sizes.
    // Scale media buckets down so (photos+videos+screenshots) == usedBytes.
    final scale = usedBytes / mediaTotal;
    photosBytes = (photosBytes * scale).floor();
    videosBytes = (videosBytes * scale).floor();
    screenshotsBytes = (usedBytes - photosBytes - videosBytes).clamp(0, usedBytes);
    otherBytes = 0;
  } else {
    otherBytes = (usedBytes - mediaTotal).clamp(0, usedBytes);
  }

  return StorageOverview(
    estimatedUsedBytes: usedBytes,
    estimatedCapacityBytes: capacityBytes,
    estimatedFreeableBytes: freeableBytes,
    categories: [
      StorageCategory(
        name: 'Photos',
        icon: Icons.photo_camera_rounded,
        color: AppColors.primary, // SkyBlue
        bytes: photosBytes,
      ),
      StorageCategory(
        name: 'Videos',
        icon: Icons.videocam_rounded,
        color: const Color(0xFF3B82F6), // Blue
        bytes: videosBytes,
      ),
      StorageCategory(
        name: 'Screenshots',
        icon: Icons.image_rounded,
        color: const Color(0xFF06B6D4), // Cyan
        bytes: screenshotsBytes,
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

