import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/providers/photo_provider.dart';

/// Bottom sheet showing grid preview of photos marked for deletion
/// with Clear All and Delete Now action buttons
class BinPreviewSheet extends ConsumerWidget {
  final Set<String> deleteQueue;
  final VoidCallback onClearAll;
  final VoidCallback onDeleteNow;

  const BinPreviewSheet({
    super.key,
    required this.deleteQueue,
    required this.onClearAll,
    required this.onDeleteNow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(filteredPhotosProvider);

    return photosAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(32),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Error loading photos',
            style: AppTextStyles.body,
          ),
        ),
      ),
      data: (allPhotos) {
        final markedPhotos = allPhotos
            .where((p) => deleteQueue.contains(p.id))
            .toList();

        // Calculate total size
        final totalSize = markedPhotos.fold(
          0,
          (sum, photo) => sum + (photo.fileSize ?? 0),
        );

        return Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marked for Deletion', style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    '${markedPhotos.length} ${markedPhotos.length == 1 ? 'photo' : 'photos'} • ${_formatBytes(totalSize)}',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ),

            // Photo grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                cacheExtent: 500,
                addAutomaticKeepAlives: false,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: markedPhotos.length,
                itemBuilder: (context, index) {
                  final photo = markedPhotos[index];
                  return RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image(
                            image: AssetEntityImageProvider(
                              photo.asset,
                              isOriginal: false,
                              thumbnailSize: const ThumbnailSize.square(200),
                            ),
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onClearAll,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: onDeleteNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text('Delete Now'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
  }
}
