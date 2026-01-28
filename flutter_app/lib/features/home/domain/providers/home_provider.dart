import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/photo_service.dart';
import '../../../photos/domain/providers/delete_queue_provider.dart';
import '../models/home_stats.dart';

/// Home statistics provider
final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  final photoService = PhotoService();
  final hasPermission = await photoService.hasPermission();

  if (!hasPermission) {
    return const HomeStats(
      totalPhotos: 0,
      totalVideos: 0,
      todayPhotos: 0,
      deleteQueueCount: 0,
      storageUsed: 0,
      storageFreeable: 0,
    );
  }

  // Get photo count
  final photoCount = await photoService.getPhotoCount(type: RequestType.image);

  // Get video count
  final videoCount = await photoService.getPhotoCount(type: RequestType.video);

  // Get today's photos
  final allPhotos = await photoService.getAllPhotos(page: 0, size: 100);
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayPhotos = allPhotos.where((photo) {
    // createDateTime is non-nullable in photo_manager, so no null check needed
    return photo.createDateTime.isAfter(todayStart);
  }).length;

  // Get delete queue count
  final deleteQueue = ref.read(deleteQueueProvider);
  final deleteQueueCount = deleteQueue.length;

  // Calculate storage (rough estimate)
  int totalSize = 0;
  for (final photo in allPhotos.take(50)) {
    // Sample first 50
    final size = await photoService.getFileSize(photo);
    totalSize += size;
  }
  final avgSize = allPhotos.isNotEmpty ? totalSize ~/ allPhotos.take(50).length : 0;
  final estimatedTotal = avgSize * photoCount;

  return HomeStats(
    totalPhotos: photoCount,
    totalVideos: videoCount,
    todayPhotos: todayPhotos,
    deleteQueueCount: deleteQueueCount,
    storageUsed: estimatedTotal,
    storageFreeable: deleteQueueCount * avgSize,
  );
});

/// Quick actions provider
final quickActionsProvider = Provider<List<QuickAction>>((ref) {
  return const [
    QuickAction(
      title: 'Swipe Review',
      subtitle: 'Quick photo cleanup',
      icon: Icons.swipe,
      route: '/swipe-review',
    ),
    QuickAction(
      title: 'Find Duplicates',
      subtitle: 'Remove similar photos',
      icon: Icons.content_copy,
      route: '/duplicates',
    ),
    QuickAction(
      title: 'Storage Stats',
      subtitle: 'View usage breakdown',
      icon: Icons.storage,
      route: '/storage-stats',
    ),
    QuickAction(
      title: 'Recently Deleted',
      subtitle: '30-day recovery',
      icon: Icons.restore_from_trash,
      route: '/recently-deleted',
    ),
  ];
});
