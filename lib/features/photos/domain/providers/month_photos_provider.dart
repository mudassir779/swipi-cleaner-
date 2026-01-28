import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/month_group.dart';
import '../models/photo.dart';
import 'photo_provider.dart';

/// Provider that groups photos by month
final monthPhotosProvider = FutureProvider<List<MonthGroup>>((ref) async {
  final photos = await ref.watch(photosProvider(0).future);
  return _groupPhotosByMonth(photos);
});

/// Provider for photos from a specific month
final monthSpecificPhotosProvider = FutureProvider.family<List<Photo>, String>((ref, monthKey) async {
  final allPhotos = await ref.watch(photosProvider(0).future);
  return allPhotos
      .where((p) => MonthGroup.getMonthKey(p.creationDate) == monthKey)
      .toList();
});

/// Provider for recent photos (last 30 days)
final recentPhotosProvider = FutureProvider<List<Photo>>((ref) async {
  final allPhotos = await ref.watch(photosProvider(0).future);
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  return allPhotos
      .where((p) => p.creationDate.isAfter(thirtyDaysAgo))
      .toList();
});

/// Provider for random shuffle of photos
final randomPhotosProvider = FutureProvider<List<Photo>>((ref) async {
  final allPhotos = await ref.watch(photosProvider(0).future);
  final shuffled = List<Photo>.from(allPhotos)..shuffle();
  return shuffled;
});

/// Provider for today's photos only
final todayPhotosProvider = FutureProvider<List<Photo>>((ref) async {
  final allPhotos = await ref.watch(photosProvider(0).future);
  final today = DateTime.now();
  return allPhotos.where((p) {
    return p.creationDate.year == today.year &&
           p.creationDate.month == today.month &&
           p.creationDate.day == today.day;
  }).toList();
});

/// Group photos by month
List<MonthGroup> _groupPhotosByMonth(List<Photo> photos) {
  // Group photos by month key
  final Map<String, List<Photo>> grouped = {};

  for (final photo in photos) {
    final monthKey = MonthGroup.getMonthKey(photo.creationDate);
    grouped.putIfAbsent(monthKey, () => []).add(photo);
  }

  // Convert to MonthGroup objects and sort by date (most recent first)
  final monthGroups = grouped.entries.map((entry) {
    final monthKey = entry.key;
    final photos = entry.value;
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return MonthGroup(
      monthKey: monthKey,
      monthDate: DateTime(year, month),
      photos: photos,
    );
  }).toList();

  // Sort by date descending (most recent first)
  monthGroups.sort((a, b) => b.monthDate.compareTo(a.monthDate));

  return monthGroups;
}
