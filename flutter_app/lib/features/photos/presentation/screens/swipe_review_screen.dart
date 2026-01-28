import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/photo.dart';
import '../../domain/providers/delete_queue_provider.dart';
import '../../domain/providers/photo_provider.dart';

/// Swipe review screen (Tinder-style card swiper)
class SwipeReviewScreen extends ConsumerStatefulWidget {
  const SwipeReviewScreen({super.key});

  @override
  ConsumerState<SwipeReviewScreen> createState() => _SwipeReviewScreenState();
}

class _SwipeReviewScreenState extends ConsumerState<SwipeReviewScreen> {
  final CardSwiperController _controller = CardSwiperController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(filteredPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Swipe Review'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading photos: $error',
            style: AppTextStyles.body.copyWith(color: AppColors.red),
          ),
        ),
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
                    'No Photos to Review',
                    style: AppTextStyles.title,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: photos.isEmpty
                              ? 0
                              : (_currentIndex + 1) / photos.length,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentIndex + 1}/${photos.length}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Card swiper
              Expanded(
                child: CardSwiper(
                  controller: _controller,
                  cardsCount: photos.length,
                  onSwipe: (previousIndex, currentIndex, direction) {
                    final photo = photos[previousIndex];

                    // Swipe left = delete, right = keep
                    if (direction == CardSwiperDirection.left) {
                      ref.read(deleteQueueProvider.notifier).add(photo.id);
                    }

                    setState(() {
                      _currentIndex = currentIndex ?? photos.length;
                    });

                    // Check if we've reviewed all photos
                    if (currentIndex == null) {
                      _showCompletionDialog(context);
                    }

                    return true;
                  },
                  cardBuilder: (context, index, horizontalOffset, verticalOffset) {
                    final photo = photos[index];
                    return _buildPhotoCard(photo);
                  },
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Keep button
                    _buildActionButton(
                      icon: Icons.check_circle_outline,
                      label: 'Keep',
                      color: AppColors.green,
                      onPressed: () {
                        _controller.swipe(CardSwiperDirection.right);
                      },
                    ),

                    // Undo button
                    _buildActionButton(
                      icon: Icons.undo,
                      label: 'Undo',
                      color: AppColors.gray,
                      onPressed: () {
                        _controller.undo();
                        if (_currentIndex > 0) {
                          setState(() => _currentIndex--);
                        }
                      },
                    ),

                    // Delete button
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: AppColors.red,
                      onPressed: () {
                        _controller.swipe(CardSwiperDirection.left);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(Photo photo) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image(
              image: AssetEntityImageProvider(
                photo.asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(800),
              ),
              fit: BoxFit.cover,
            ),

            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (photo.title != null)
                      Text(
                        photo.title!,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${photo.width} × ${photo.height}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.storage,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          photo.formattedSize,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: color,
          heroTag: label,
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog(BuildContext context) {
    final deleteQueue = ref.read(deleteQueueProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Complete'),
        content: Text(
          'You\'ve reviewed all photos!\n\n'
          '${deleteQueue.length} ${deleteQueue.length == 1 ? 'photo' : 'photos'} marked for deletion.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close swipe screen
            },
            child: const Text('Done'),
          ),
          if (deleteQueue.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close swipe screen
                // TODO: Navigate to delete confirmation
              },
              child: const Text('Review & Delete'),
            ),
        ],
      ),
    );
  }
}
