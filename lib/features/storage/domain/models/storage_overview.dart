import 'storage_category.dart';

class StorageOverview {
  final int estimatedUsedBytes;
  final int estimatedCapacityBytes;
  final int estimatedFreeableBytes;
  final List<StorageCategory> categories;

  const StorageOverview({
    required this.estimatedUsedBytes,
    required this.estimatedCapacityBytes,
    required this.estimatedFreeableBytes,
    required this.categories,
  });
}

