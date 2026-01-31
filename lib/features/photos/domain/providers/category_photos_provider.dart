import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/photo.dart';
import 'photo_provider.dart';

/// Screenshots derived from filename heuristics.
final screenshotsProvider = FutureProvider<List<Photo>>((ref) async {
  final service = ref.read(photoServiceProvider);
  final hasPermission = await service.hasPermission();
  if (!hasPermission) return [];

  // Prefer the OS "Screenshots" album when present (more reliable than filename heuristics).
  final assets = <AssetEntity>[
    ...await service.getScreenshots(page: 0, size: 200),
    ...await service.getScreenshots(page: 1, size: 200),
  ];
  return assets.map((a) => Photo.fromAssetSync(a)).toList();
});

/// Videos (first page) - enough for category preview & swipe flows.
final videosProvider = FutureProvider<List<Photo>>((ref) async {
  final service = ref.read(photoServiceProvider);
  final hasPermission = await service.hasPermission();
  if (!hasPermission) return [];

  final assets = await service.getAllPhotos(page: 0, size: 100, type: RequestType.video);
  return Future.wait(assets.map((a) => Photo.fromAsset(a)));
});

/// Large videos (>50MB) from the first page.
final largeVideosProvider = FutureProvider<List<Photo>>((ref) async {
  final videos = await ref.watch(videosProvider.future);
  return videos.where((v) => (v.fileSize ?? 0) > 50 * 1024 * 1024).toList();
});

