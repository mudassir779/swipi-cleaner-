import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/photo_grid_item.dart';
import '../domain/providers/month_photos_provider.dart';
import 'widgets/app_drawer.dart';
import 'widgets/month_picker_sheet.dart';

/// Photos screen with month-by-month organization
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showMonthPickerFAB = true;
  final Set<String> _expandedMonths = {}; // Track which months are expanded

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Hide FAB when scrolling down, show when scrolling up
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _showMonthPickerFAB) {
      setState(() => _showMonthPickerFAB = false);
    } else if (direction == ScrollDirection.forward && !_showMonthPickerFAB) {
      setState(() => _showMonthPickerFAB = true);
    }
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MonthPickerSheet(
        onMonthSelected: _scrollToMonth,
      ),
    );
  }

  void _scrollToMonth(String monthKey) {
    final monthGroupsAsync = ref.read(monthPhotosProvider);

    monthGroupsAsync.whenData((monthGroups) {
      // Find index of the selected month
      final index = monthGroups.indexWhere((g) => g.monthKey == monthKey);

      if (index == -1) return;

      // Calculate approximate offset
      // Each section has: header (56px) + photos grid
      // Approximate grid height based on 3-column grid with aspect ratio 1:1
      double offset = 0;
      for (int i = 0; i < index; i++) {
        offset += 56; // Header height
        if (monthGroups[i].photoCount > 0) {
          // Calculate grid rows
          final rows = (monthGroups[i].photoCount / 3).ceil();
          final screenWidth = MediaQuery.of(context).size.width;
          final itemSize = (screenWidth - 8) / 3; // 3 columns with 2px spacing
          offset += rows * (itemSize + 2) + 4; // Add grid height + padding
        }
      }

      // Animate to calculated offset
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthGroupsAsync = ref.watch(monthPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      floatingActionButton: _buildFABs(context, ref),
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
              controller: _scrollController,
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

  /// Build floating action buttons
  Widget? _buildFABs(BuildContext context, WidgetRef ref) {
    final todayPhotosAsync = ref.watch(todayPhotosProvider);

    return todayPhotosAsync.when(
      data: (photos) {
        final hasToday = photos.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Month picker FAB (always visible when not scrolling down)
            AnimatedScale(
              scale: _showMonthPickerFAB ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: FloatingActionButton(
                heroTag: 'month_picker',
                onPressed: _showMonthPicker,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.calendar_month, color: Colors.white),
              ),
            ),

            // Spacing if both FABs are shown
            if (hasToday) const SizedBox(height: 16),

            // Clean Today FAB (conditional)
            if (hasToday)
              FloatingActionButton.extended(
                heroTag: 'clean_today',
                onPressed: () => context.push('/swipe-review?filter=today'),
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.today),
                label: const Text(
                  'Clean Today',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => null,
      error: (err, st) => null,
    );
  }

  /// Toggle month expansion
  void _toggleMonth(String monthKey) {
    setState(() {
      if (_expandedMonths.contains(monthKey)) {
        _expandedMonths.remove(monthKey);
      } else {
        _expandedMonths.add(monthKey);
      }
    });
  }

  /// Build month section with sticky header and photo grid
  List<Widget> _buildMonthSection(BuildContext context, monthGroup, int index) {
    final isEmpty = monthGroup.photoCount == 0;
    final isExpanded = _expandedMonths.contains(monthGroup.monthKey);

    return [
      // Sticky month header (tappable to expand/collapse)
      SliverPersistentHeader(
        pinned: true,
        delegate: _MonthHeaderDelegate(
          monthGroup: monthGroup,
          isEmpty: isEmpty,
          isExpanded: isExpanded,
          onTap: () => _toggleMonth(monthGroup.monthKey),
        ),
      ),

      // Photo grid for this month (only if expanded)
      if (!isEmpty && isExpanded)
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
                  index: photoIndex,
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
  final bool isExpanded;
  final VoidCallback onTap;

  _MonthHeaderDelegate({
    required this.monthGroup,
    required this.isEmpty,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            const SizedBox(width: 8),
            // Chevron icon (rotates based on expanded state)
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0, // 180 degrees when expanded
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: isEmpty
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_MonthHeaderDelegate oldDelegate) {
    return monthGroup != oldDelegate.monthGroup ||
           isEmpty != oldDelegate.isEmpty ||
           isExpanded != oldDelegate.isExpanded;
  }
}
