import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/photo.dart';
import '../../domain/providers/delete_queue_provider.dart';
import '../../domain/providers/photo_provider.dart';
import '../../domain/providers/month_photos_provider.dart';
import '../widgets/floating_bubble.dart';
import '../widgets/bin_preview_sheet.dart';

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

  /// Get photos based on query parameters
  AsyncValue<List<Photo>> _getFilteredPhotos() {
    final uri = GoRouterState.of(context).uri;
    final monthParam = uri.queryParameters['month'];
    final filterParam = uri.queryParameters['filter'];

    if (monthParam != null) {
      return ref.watch(monthSpecificPhotosProvider(monthParam));
    } else if (filterParam == 'recents') {
      return ref.watch(recentPhotosProvider);
    } else if (filterParam == 'random') {
      return ref.watch(randomPhotosProvider);
    } else if (filterParam == 'today') {
      return ref.watch(todayPhotosProvider);
    }
    return ref.watch(filteredPhotosProvider);
  }

  /// Get title based on query parameters
  String _getTitle() {
    final uri = GoRouterState.of(context).uri;
    final monthParam = uri.queryParameters['month'];
    final filterParam = uri.queryParameters['filter'];

    if (monthParam != null) {
      // Format month key "2025-12" to "DEC '25"
      final parts = monthParam.split('-');
      if (parts.length == 2) {
        const monthAbbr = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        final year = parts[0];
        final month = int.tryParse(parts[1]);
        if (month != null && month >= 1 && month <= 12) {
          return "${monthAbbr[month - 1]} '${year.substring(2)}";
        }
      }
      return monthParam;
    } else if (filterParam == 'recents') {
      return 'Recents';
    } else if (filterParam == 'random') {
      return 'Random';
    } else if (filterParam == 'today') {
      return 'Today';
    }
    return 'Swipe Review';
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = _getFilteredPhotos();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
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

          final deleteQueue = ref.watch(deleteQueueProvider);

          return Stack(
            children: [
              // Main content
              Column(
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
                              backgroundColor: AppColors.cardBackground,
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
                        return _buildPhotoCardWithOverlay(photo, horizontalOffset.toDouble(), verticalOffset.toDouble());
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
              ),

              // Floating bubble (only when delete queue is not empty)
              if (deleteQueue.isNotEmpty)
                Positioned(
                  top: 80,
                  right: 16,
                  child: FloatingBubble(
                    count: deleteQueue.length,
                    onTap: () => _showBinBottomSheet(),
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
                thumbnailSize: ThumbnailSize(800, 800),
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

  /// Build photo card with swipe overlay animations
  Widget _buildPhotoCardWithOverlay(Photo photo, double horizontalOffset, double verticalOffset) {
    // Calculate swipe progress (-1 to 1)
    final swipeProgress = (horizontalOffset / 100).clamp(-1.0, 1.0);

    return Stack(
      children: [
        // Base photo card
        _buildPhotoCard(photo),

        // Left swipe (delete) - Red overlay
        if (swipeProgress < -0.1)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: swipeProgress.abs(),
              duration: Duration.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),

        // Right swipe (keep) - Green overlay
        if (swipeProgress > 0.1)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: swipeProgress.abs(),
              duration: Duration.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
      ],
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

  /// Show bottom sheet with grid of marked photos
  void _showBinBottomSheet() {
    final deleteQueue = ref.read(deleteQueueProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BinPreviewSheet(
              deleteQueue: deleteQueue,
              onClearAll: () {
                ref.read(deleteQueueProvider.notifier).clear();
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bin cleared'),
                      backgroundColor: AppColors.green,
                    ),
                  );
                }
              },
              onDeleteNow: () {
                Navigator.pop(context); // Close bottom sheet
                context.go('/confirm-delete'); // Navigate to confirmation screen
              },
            ),
          );
        },
      ),
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
                context.go('/confirm-delete'); // Navigate to confirmation screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
              ),
              child: const Text('Review & Delete'),
            ),
        ],
      ),
    );
  }
}
