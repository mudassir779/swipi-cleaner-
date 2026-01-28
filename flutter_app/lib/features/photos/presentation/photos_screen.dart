import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/photo_grid_item.dart';
import '../domain/providers/month_photos_provider.dart';
import 'widgets/app_drawer.dart';

/// Photos screen with month-by-month organization
class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthGroupsAsync = ref.watch(monthPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      floatingActionButton: _buildQuickCleanButton(context, ref),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 60,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Photos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: monthGroupsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading photos',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (monthGroups) {
          if (monthGroups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Photos',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your photos will appear here',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(monthPhotosProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Build sliver grid for each month
                for (int i = 0; i < monthGroups.length; i++)
                  ..._buildMonthSection(context, monthGroups[i], i),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build floating quick clean button (shows when today has photos)
  Widget? _buildQuickCleanButton(BuildContext context, WidgetRef ref) {
    final todayPhotosAsync = ref.watch(todayPhotosProvider);

    return todayPhotosAsync.when(
      data: (photos) {
        // Only show button if today has photos
        if (photos.isEmpty) return null;

        return FloatingActionButton.extended(
          onPressed: () => context.push('/swipe-review?filter=today'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.today),
          label: const Text(
            'Clean Today',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// Build month section with sticky header and photo grid
  List<Widget> _buildMonthSection(BuildContext context, monthGroup, int index) {
    final isEmpty = monthGroup.photoCount == 0;

    return [
      // Sticky month header
      SliverPersistentHeader(
        pinned: true,
        delegate: _MonthHeaderDelegate(
          monthGroup: monthGroup,
          isEmpty: isEmpty,
        ),
      ),

      // Photo grid for this month
      if (!isEmpty)
        SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, photoIndex) {
                final photo = monthGroup.photos[photoIndex];
                return PhotoGridItem(
                  asset: photo.asset,
                  isSelected: false,
                  onTap: () {
                    // Navigate to swipe review starting from this photo
                    context.push(
                      '/swipe-review?month=${monthGroup.monthKey}&start=$photoIndex',
                    );
                  },
                );
              },
              childCount: monthGroup.photos.length,
            ),
          ),
        ),

      // Empty state for months with no photos
      if (isEmpty)
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No photos in ${monthGroup.displayName}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
    ];
  }
}

/// Sticky header delegate for month headers
class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final dynamic monthGroup;
  final bool isEmpty;

  _MonthHeaderDelegate({
    required this.monthGroup,
    required this.isEmpty,
  });

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Coral dot indicator (grayed out for empty months)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isEmpty
                  ? AppColors.textSecondary.withValues(alpha: 0.3)
                  : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Month name
          Text(
            monthGroup.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: isEmpty
                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                  : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Photo count
          Text(
            '${monthGroup.photoCount} photos',
            style: TextStyle(
              fontSize: 15,
              color: isEmpty
                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_MonthHeaderDelegate oldDelegate) {
    return monthGroup != oldDelegate.monthGroup || isEmpty != oldDelegate.isEmpty;
  }
}
