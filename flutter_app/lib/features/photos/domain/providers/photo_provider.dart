import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../shared/services/photo_service.dart';
import '../models/photo.dart';
import '../models/photo_filter.dart';
import 'filter_provider.dart';

/// Photo service provider
final photoServiceProvider = Provider((ref) => PhotoService());

/// Permission status provider
final permissionStatusProvider = FutureProvider<PermissionState>((ref) async {
  final service = ref.read(photoServiceProvider);
  return await service.requestPermission();
});

/// Photo count provider
final photoCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(photoServiceProvider);
  final hasPermission = await service.hasPermission();
  if (!hasPermission) return 0;
  return await service.getPhotoCount();
});

/// Photos list provider with pagination
final photosProvider =
    FutureProvider.family<List<Photo>, int>((ref, page) async {
  final service = ref.read(photoServiceProvider);
  final hasPermission = await service.hasPermission();

  if (!hasPermission) return [];

  final assets = await service.getAllPhotos(page: page, size: 100);

  // Convert AssetEntity to Photo model (fast - no file I/O)
  final photos = assets.map((asset) => Photo.fromAssetFast(asset)).toList();

  return photos;
});

/// Filtered photos provider
final filteredPhotosProvider = FutureProvider<List<Photo>>((ref) async {
  final filter = ref.watch(filterProvider);
  final allPhotos = await ref.watch(photosProvider(0).future);

  // Apply filters
  var filtered = allPhotos;

  // Date filter
  if (filter.datePreset != DateFilterPreset.all &&
      filter.startDate != null &&
      filter.endDate != null) {
    filtered = filtered.where((photo) {
      return photo.creationDate.isAfter(filter.startDate!) &&
          photo.creationDate.isBefore(filter.endDate!);
    }).toList();
  }

  // Size filter
  switch (filter.sizeFilter) {
    case SizeFilter.large:
      filtered = filtered.where((photo) =>
        photo.fileSize != null && photo.fileSize! > 10 * 1024 * 1024
      ).toList();
      break;
    case SizeFilter.medium:
      filtered = filtered.where((photo) =>
        photo.fileSize != null &&
        photo.fileSize! >= 5 * 1024 * 1024 &&
        photo.fileSize! <= 10 * 1024 * 1024
      ).toList();
      break;
    case SizeFilter.small:
      filtered = filtered.where((photo) =>
        photo.fileSize != null && photo.fileSize! < 5 * 1024 * 1024
      ).toList();
      break;
    case SizeFilter.all:
      break;
  }

  // Search query - filter by filename/title
  if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
    final query = filter.searchQuery!.toLowerCase();
    filtered = filtered.where((photo) {
      // Photos without titles won't match any search query
      return photo.title?.toLowerCase().contains(query) ?? false;
    }).toList();
  }

  // Sorting
  filtered.sort((a, b) {
    int comparison;
    switch (filter.sortBy) {
      case SortBy.date:
        comparison = a.creationDate.compareTo(b.creationDate);
        break;
      case SortBy.size:
        final aSize = a.fileSize ?? 0;
        final bSize = b.fileSize ?? 0;
        comparison = aSize.compareTo(bSize);
        break;
      case SortBy.name:
        final aTitle = a.title ?? '';
        final bTitle = b.title ?? '';
        comparison = aTitle.compareTo(bTitle);
        break;
    }
    return filter.sortOrder == SortOrder.asc ? comparison : -comparison;
  });

  return filtered;
});

/// All photos provider - loads ALL photos in batches for accurate stats
/// WARNING: This can be slow for large libraries, use sparingly
final allPhotosProvider = FutureProvider<List<Photo>>((ref) async {
  final service = ref.read(photoServiceProvider);
  final hasPermission = await service.hasPermission();

  if (!hasPermission) return [];

  // Get total count first
  final totalCount = await service.getPhotoCount();

  // Load all photos in batches of 100
  List<Photo> allPhotos = [];
  int page = 0;
  const pageSize = 100;

  while (allPhotos.length < totalCount) {
    final assets = await service.getAllPhotos(page: page, size: pageSize);

    if (assets.isEmpty) break; // No more photos

    // Convert AssetEntity to Photo model (fast - no file I/O)
    final photos = assets.map((asset) => Photo.fromAssetFast(asset)).toList();

    allPhotos.addAll(photos);
    page++;

    // Safety check - prevent infinite loop
    if (page > 1000) break; // Max 100,000 photos
  }

  return allPhotos;
});
