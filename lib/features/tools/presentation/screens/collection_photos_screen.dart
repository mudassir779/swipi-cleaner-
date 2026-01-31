import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../photos/domain/providers/delete_queue_provider.dart';
import '../../../photos/domain/providers/photo_provider.dart';
import '../../../photos/domain/models/photo.dart';

/// Types of smart collections
enum CollectionType {
  large,
  old,
  screenshots,
}

/// Provider for collection photos based on type
final collectionPhotosProvider = FutureProvider.family<List<Photo>, CollectionType>((ref, type) async {
  final allPhotos = await ref.watch(allPhotosProvider.future);
  
  List<Photo> filtered = [];

  switch (type) {
    case CollectionType.large:
      // Optimized Large File Search:
      // 1. Check ALL videos (most likely to be large)
      // 2. Check photos, but maybe limit checking to avoid performance issues if library is huge? 
      //    For now, we'll check all videos and photos since we need to find them.
      //    To be safe, we'll prioritize videos.
      
      final videos = allPhotos.where((p) => p.asset.type == AssetType.video).toList();
      final photos = allPhotos.where((p) => p.asset.type == AssetType.image).toList();
      
      // Hydrate videos first (higher probability)
      final hydratedVideos = await Future.wait(
        videos.map((p) => Photo.fromAsset(p.asset))
      );
      
      // Hydrate photos (might be slow for huge libraries, but necessary for correctness)
      // We process photos in batches to avoid choking the UI/Task
      final largePhotos = <Photo>[];
      const batchSize = 50;
      for (var i = 0; i < photos.length; i += batchSize) {
        final end = (i + batchSize < photos.length) ? i + batchSize : photos.length;
        final batch = photos.sublist(i, end);
        final hydratedBatch = await Future.wait(batch.map((p) => Photo.fromAsset(p.asset)));
        largePhotos.addAll(hydratedBatch.where((p) => (p.fileSize ?? 0) > 10 * 1024 * 1024));
        
        // Safety break if we found enough to populate the UI (optional optimization)
        // if (largePhotos.length > 50) break; 
      }
      
      final largeVideos = hydratedVideos.where((p) => (p.fileSize ?? 0) > 10 * 1024 * 1024).toList();
      
      return [...largeVideos, ...largePhotos]..sort((a, b) => (b.fileSize ?? 0).compareTo(a.fileSize ?? 0));

    case CollectionType.old:
      // Filter first (fast)
      final candidates = allPhotos.where((p) => p.isOld).toList();
      // Then hydrate sizes (slow but minimal set)
      return await Future.wait(candidates.map((p) => Photo.fromAsset(p.asset)));

    case CollectionType.screenshots:
      // Filter first (fast)
      final candidates = allPhotos.where((p) => 
        (p.title?.toLowerCase().contains('screenshot') ?? false) ||
        (p.asset.relativePath?.toLowerCase().contains('screenshot') ?? false)
      ).toList();
      // Then hydrate sizes
      return await Future.wait(candidates.map((p) => Photo.fromAsset(p.asset)));
  }
});

/// Screen to display photos from a smart collection with selection
class CollectionPhotosScreen extends ConsumerStatefulWidget {
  final CollectionType collectionType;
  
  const CollectionPhotosScreen({
    super.key,
    required this.collectionType,
  });

  @override
  ConsumerState<CollectionPhotosScreen> createState() => _CollectionPhotosScreenState();
}

class _CollectionPhotosScreenState extends ConsumerState<CollectionPhotosScreen> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  String get _title {
    switch (widget.collectionType) {
      case CollectionType.large:
        return 'Large Files';
      case CollectionType.old:
        return 'Old Photos';
      case CollectionType.screenshots:
        return 'Screenshots';
    }
  }

  String get _subtitle {
    switch (widget.collectionType) {
      case CollectionType.large:
        return 'Photos larger than 10MB';
      case CollectionType.old:
        return 'Photos older than 1 year';
      case CollectionType.screenshots:
        return 'Screen captures';
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll(List<Photo> photos) {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(photos.map((p) => p.id));
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  void _addToDeleteQueue(List<Photo> photos) {
    final selectedPhotos = photos.where((p) => _selectedIds.contains(p.id)).toList();
    ref.read(deleteQueueProvider.notifier).addAll(selectedPhotos.map((p) => p.id).toList());
    context.push('/confirm-delete');
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(collectionPhotosProvider(widget.collectionType));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSelectionMode)
            TextButton(
              onPressed: _clearSelection,
              child: const Text('Clear'),
            )
          else
            photosAsync.maybeWhen(
              data: (photos) => TextButton(
                onPressed: photos.isNotEmpty ? () => _selectAll(photos) : null,
                child: const Text('Select All'),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading photos', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(e.toString(), style: AppTextStyles.body),
            ],
          ),
        ),
        data: (photos) {
          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_title.toLowerCase()} found!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your gallery is clean',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final totalSize = photos.fold<int>(0, (sum, p) => sum + (p.fileSize ?? 0));

          return Column(
            children: [
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).cardTheme.color,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${photos.length} items • ${formatBytes(totalSize)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (_isSelectionMode)
                      Text(
                        '${_selectedIds.length} selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Photo grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    final isSelected = _selectedIds.contains(photo.id);

                    return GestureDetector(
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(photo.id);
                        } else {
                          context.push('/photo-details', extra: {
                            'asset': photo.asset,
                            'photoId': photo.id,
                          });
                        }
                      },
                      onLongPress: () => _toggleSelection(photo.id),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image(
                              image: AssetEntityImageProvider(
                                photo.asset,
                                isOriginal: false,
                                thumbnailSize: const ThumbnailSize(200, 200),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Size badge for large files
                          if (widget.collectionType == CollectionType.large)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  formatBytes(photo.fileSize ?? 0),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          // Selection overlay
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _isSelectionMode
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: SafeArea(
                child: photosAsync.maybeWhen(
                  data: (photos) => ElevatedButton.icon(
                    onPressed: _selectedIds.isNotEmpty ? () => _addToDeleteQueue(photos) : null,
                    icon: const Icon(Icons.delete_outline),
                    label: Text('Delete ${_selectedIds.length} items'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            )
          : null,
    );
  }
}
