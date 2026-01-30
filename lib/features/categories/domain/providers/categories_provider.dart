import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../photos/domain/providers/category_photos_provider.dart';
import '../../../photos/domain/providers/photo_provider.dart';
import '../models/category_item.dart';

final categoriesProvider = FutureProvider<List<CategoryItem>>((ref) async {
  // Base photos count (images)
  final photoCount = await ref.watch(photoCountProvider.future);

  final screenshots = await ref.watch(screenshotsProvider.future);
  final largeVideos = await ref.watch(largeVideosProvider.future);

  return [
    CategoryItem(
      id: 'screenshots',
      title: 'Screenshots',
      icon: Icons.phone_iphone_rounded,
      accent: const Color(0xFF3B82F6),
      count: screenshots.length,
      previews: screenshots.take(4).map((p) => p.asset).toList(),
    ),
    CategoryItem(
      id: 'selfies',
      title: 'Selfies',
      icon: Icons.face_rounded,
      accent: const Color(0xFFEC4899),
      count: 0,
      previews: const [],
      comingSoon: true,
    ),
    CategoryItem(
      id: 'blurry',
      title: 'Blurry Photos',
      icon: Icons.blur_on_rounded,
      accent: const Color(0xFF6B7280),
      count: 0,
      previews: const [],
      comingSoon: true,
    ),
    CategoryItem(
      id: 'similar',
      title: 'Similar Photos',
      icon: Icons.loop_rounded,
      accent: const Color(0xFFF59E0B),
      count: 0,
      previews: const [],
      comingSoon: true,
    ),
    CategoryItem(
      id: 'large_videos',
      title: 'Large Videos',
      icon: Icons.videocam_rounded,
      accent: const Color(0xFF8B5CF6),
      count: largeVideos.length,
      previews: largeVideos.take(4).map((p) => p.asset).toList(),
    ),
    CategoryItem(
      id: 'downloads',
      title: 'Old Downloads',
      icon: Icons.download_rounded,
      accent: const Color(0xFF22C55E),
      count: photoCount == 0 ? 0 : 0,
      previews: const [],
      comingSoon: true,
    ),
  ];
});

