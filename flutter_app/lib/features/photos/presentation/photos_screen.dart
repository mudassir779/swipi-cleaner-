import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/photo_grid_item.dart';
import '../domain/providers/delete_queue_provider.dart';
import '../domain/providers/filter_provider.dart';
import '../domain/providers/photo_provider.dart';
import 'widgets/delete_queue_banner.dart';
import 'widgets/filter_bottom_sheet.dart';

/// Photos screen with photo grid and filters
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(filteredPhotosProvider);
    final deleteQueue = ref.watch(deleteQueueProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${deleteQueue.length} selected'
            : 'Photos'),
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: () {
                ref.read(deleteQueueProvider.notifier).deselectAll();
                setState(() => _isSelectionMode = false);
              },
              child: const Text('Cancel'),
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                photosAsync.whenData((photos) {
                  final allIds = photos.map((p) => p.id).toList();
                  ref.read(deleteQueueProvider.notifier).selectAll(allIds);
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Open search
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search coming soon')),
                );
              },
            ),
            IconButton(
              icon: Badge(
                isLabelVisible: filter.hasActiveFilters,
                child: const Icon(Icons.filter_list),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const FilterBottomSheet(),
                  backgroundColor: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: photosAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                // Check if it's a permission error
                if (error.toString().contains('permission')) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Photo Access Required',
                            style: AppTextStyles.title,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please grant permission to access your photos in Settings',
                            style: AppTextStyles.subtitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Open app settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enable photo access in Settings'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Open Settings'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: Text(
                    'Error loading photos: $error',
                    style: AppTextStyles.body.copyWith(color: AppColors.red),
                  ),
                );
              },
              data: (photos) {
                if (photos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Photos Found',
                          style: AppTextStyles.title,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your photo library is empty',
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredPhotosProvider);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppConstants.photoGridColumns,
                      crossAxisSpacing: AppConstants.photoGridSpacing,
                      mainAxisSpacing: AppConstants.photoGridSpacing,
                      childAspectRatio: AppConstants.photoGridAspectRatio,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      final isSelected = deleteQueue.contains(photo.id);

                      return PhotoGridItem(
                        asset: photo.asset,
                        isSelected: isSelected,
                        onTap: () {
                          if (_isSelectionMode) {
                            ref.read(deleteQueueProvider.notifier).toggle(photo.id);
                          } else {
                            // Open photo details
                            context.push('/photo-details', extra: {
                              'asset': photo.asset,
                              'photoId': photo.id,
                            });
                          }
                        },
                        onLongPress: () {
                          if (!_isSelectionMode) {
                            setState(() => _isSelectionMode = true);
                            ref.read(deleteQueueProvider.notifier).add(photo.id);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Delete queue banner
          if (deleteQueue.isNotEmpty)
            DeleteQueueBanner(
              count: deleteQueue.length,
              onTap: () {
                context.push('/confirm-delete');
              },
            ),
        ],
      ),
      floatingActionButton: !_isSelectionMode && photosAsync.hasValue
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/swipe-review');
              },
              icon: const Icon(Icons.swipe),
              label: const Text('Swipe Review'),
            )
          : null,
    );
  }
}
