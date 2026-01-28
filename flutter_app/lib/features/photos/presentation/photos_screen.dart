import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/providers/month_photos_provider.dart';
import '../domain/providers/filter_provider.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/app_drawer.dart';

/// Photos screen with month-by-month organization
class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthGroupsAsync = ref.watch(monthPhotosProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Photos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon')),
              );
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: filter.hasActiveFilters,
              child: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const FilterBottomSheet(),
                backgroundColor: AppColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              );
            },
          ),
        ],
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
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: monthGroups.length + 1, // +1 for quick access section
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildQuickAccessSection(context, ref);
                }
                final monthGroup = monthGroups[index - 1];
                return _buildMonthBand(context, monthGroup, index - 1);
              },
            ),
          );
        },
      ),
    );
  }

  /// Quick access section with Recents, Random, Today
  Widget _buildQuickAccessSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  title: 'Recents',
                  subtitle: '30 days',
                  icon: Icons.access_time,
                  onTap: () => context.push('/swipe-review?filter=recents'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  title: 'Random',
                  subtitle: 'Shuffle',
                  icon: Icons.shuffle,
                  onTap: () => context.push('/swipe-review?filter=random'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  title: 'Today',
                  subtitle: DateTime.now().day.toString(),
                  icon: Icons.today,
                  onTap: () => context.push('/swipe-review?filter=today'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick access card widget
  Widget _buildQuickAccessCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Month band widget
  Widget _buildMonthBand(BuildContext context, monthGroup, int index) {
    final isEmpty = monthGroup.photoCount == 0;

    return InkWell(
      onTap: () {
        // Check if month is empty before navigating
        if (isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No photos in ${monthGroup.displayName}'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textSecondary,
            ),
          );
          return; // Don't navigate
        }
        context.push('/swipe-review?month=${monthGroup.monthKey}');
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isEmpty
              ? AppColors.cardBackground.withOpacity(0.5)
              : monthGroup.getBackgroundColor(index),
          border: const Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Blue dot indicator (grayed out for empty months)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isEmpty
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            // Month name (grayed out for empty months)
            Text(
              monthGroup.displayName,
              style: TextStyle(
                color: isEmpty
                    ? AppColors.textSecondary.withOpacity(0.5)
                    : AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Photo count (grayed out for empty months)
            Text(
              '${monthGroup.photoCount} photos',
              style: TextStyle(
                color: isEmpty
                    ? AppColors.textSecondary.withOpacity(0.5)
                    : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            // Arrow icon
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
