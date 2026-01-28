import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  void initState() {
    super.initState();

    // Get start index from query params for tap-to-swipe navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final startParam = uri.queryParameters['start'];
      if (startParam != null) {
        final startIndex = int.tryParse(startParam) ?? 0;
        setState(() => _currentIndex = startIndex);
        // Note: CardSwiper doesn't support initialIndex, so we start from 0
        // This will be enhanced when implementing photo grid navigation
      }
    });
  }

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
          onPressed: () => context.pop(),
        ),
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.red.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oops!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We couldn\'t load your photos.\nPlease check your permissions and try again.',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Back to Photos'),
                ),
              ],
            ),
          ),
        ),
        data: (photos) {
          // EARLY RETURN if no photos - prevents CardSwiper crash
          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'All clean! 🎉',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pick another month to keep cleaning',
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Back to Photos'),
                  ),
                ],
              ),
            );
          }

          // Only build CardSwiper if we have photos
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
                              value: (_currentIndex + 1) / photos.length,
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
                      numberOfCardsDisplayed: photos.length >= 2 ? 2 : 1,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        final photo = photos[previousIndex];

                        // Add haptic feedback based on swipe direction
                        if (direction == CardSwiperDirection.left) {
                          HapticFeedback.mediumImpact(); // Medium vibration for delete
                          ref.read(deleteQueueProvider.notifier).add(photo.id);
                        } else if (direction == CardSwiperDirection.right) {
                          HapticFeedback.lightImpact(); // Light vibration for keep
                        }

                        setState(() {
                          // Clamp currentIndex to valid range [0, photos.length - 1]
                          // When null (swipe complete), set to last valid index
                          _currentIndex = (currentIndex ?? photos.length - 1).clamp(0, photos.length - 1);
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

                  // Gesture-only - no action buttons for cleaner experience
                  const SizedBox(height: 24),
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
              opacity: (swipeProgress.abs() * 1.3).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: swipeProgress.abs() > 0.3 ? 1.1 : 1.0),
                    duration: const Duration(milliseconds: 100),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 120,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

        // Right swipe (keep) - Green overlay
        if (swipeProgress > 0.1)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: (swipeProgress.abs() * 1.3).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: swipeProgress.abs() > 0.3 ? 1.1 : 1.0),
                    duration: const Duration(milliseconds: 100),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 120,
                        ),
                      );
                    },
                  ),
                ),
              ),
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
                // Silent operation - bubble disappears automatically
              },
              onDeleteNow: () {
                Navigator.pop(context); // Close bottom sheet
                context.push('/confirm-delete'); // Navigate to confirmation screen
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
        backgroundColor: AppColors.surface,
        title: const Text(
          'Great work! 🎉',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          deleteQueue.isEmpty
              ? 'You\'ve reviewed all photos and kept them all!'
              : 'You reviewed all the photos!\n\n'
                  '${deleteQueue.length} ${deleteQueue.length == 1 ? 'photo' : 'photos'} marked for deletion.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Close swipe screen
            },
            child: const Text('Done'),
          ),
          if (deleteQueue.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.push('/confirm-delete'); // Navigate to confirmation screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Review & Delete'),
            ),
        ],
      ),
    );
  }
}
