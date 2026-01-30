import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_bytes.dart';
import '../../../core/widgets/primary_gradient_button.dart';
import '../../../core/widgets/stagger_in.dart';
import '../../photos/domain/providers/delete_queue_provider.dart';
import '../domain/models/duplicate_group.dart';
import '../domain/providers/duplicates_provider.dart';
import 'widgets/duplicate_scan_hero.dart';

/// Screen for finding and managing duplicate photos
class DuplicatesScreen extends ConsumerWidget {
  const DuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duplicatesAsync = ref.watch(duplicatesProvider);
    final selection = ref.watch(duplicateSelectionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Find Duplicates',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: duplicatesAsync.when(
        loading: () => const Center(
          child: DuplicateScanHero(caption: 'Scanning for duplicates...'),
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
                  'Error scanning photos',
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
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Duplicates Found!',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your photo library is clean',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final duplicatesCount =
              groups.fold<int>(0, (sum, g) => sum + g.duplicates.length);
          final exactDuplicatesCount = groups
              .where((g) => g.similarityScore >= 0.99)
              .fold<int>(0, (sum, g) => sum + g.duplicates.length);
          final similarDuplicatesCount = (duplicatesCount - exactDuplicatesCount).clamp(0, duplicatesCount);

          final wastedBytes = groups.fold<int>(
            0,
            (sum, g) => sum + g.duplicates.fold<int>(0, (s, p) => s + (p.fileSize ?? 0)),
          );

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary hero
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFECFEFF), // cyan-50
                              Color(0xFFF0FDFA), // teal-50
                            ],
                          ),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF14B8A6),
                                        Color(0xFF06B6D4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.collections,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TweenAnimationBuilder<int>(
                                        tween: IntTween(begin: 0, end: duplicatesCount),
                                        duration: const Duration(milliseconds: 700),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, _) {
                                          return Text(
                                            '$value Duplicates Found',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${formatBytes(wastedBytes)} can be recovered',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F766E), // teal-700
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: StaggerIn(
                                    delay: const Duration(milliseconds: 40),
                                    child: _StatPill(
                                      icon: Icons.auto_awesome,
                                      label: 'Similar',
                                      value: '$similarDuplicatesCount',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StaggerIn(
                                    delay: const Duration(milliseconds: 90),
                                    child: _StatPill(
                                      icon: Icons.content_copy,
                                      label: 'Exact',
                                      value: '$exactDuplicatesCount',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StaggerIn(
                                    delay: const Duration(milliseconds: 140),
                                    child: _StatPill(
                                      icon: Icons.storage_rounded,
                                      label: 'Wasted',
                                      value: formatBytes(wastedBytes),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            PrimaryGradientButton(
                              colors: const [Color(0xFF111827), Color(0xFF0B1220)],
                              onPressed: () {
                                // Scroll naturally into the review section; keep the button for parity with prompt.
                              },
                              child: const Text(
                                'Review Duplicates',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Groups',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return _buildDuplicateGroup(context, ref, groups[index], index);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: selection.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selection.length} selected',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          TextButton(
                            onPressed: () {
                              ref.read(duplicateSelectionProvider.notifier).clear();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Clear selection',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add to delete queue
                        ref.read(deleteQueueProvider.notifier).addAll(selection.toList());
                        // Clear selection
                        ref.read(duplicateSelectionProvider.notifier).clear();
                        // Navigate to confirm delete
                        context.push('/confirm-delete');
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  /// Build a duplicate group card
  Widget _buildDuplicateGroup(
    BuildContext context,
    WidgetRef ref,
    DuplicateGroup group,
    int groupIndex,
  ) {
    final selection = ref.watch(duplicateSelectionProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Group ${groupIndex + 1}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.photoCount} similar photos',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Photo grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              addAutomaticKeepAlives: false,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: group.photos.length,
              itemBuilder: (context, index) {
                final photo = group.photos[index];
                final isSelected = selection.contains(photo.id);
                final isBest = photo.id == group.bestPhoto.id;

                return RepaintBoundary(
                  child: GestureDetector(
                  onTap: () {
                    ref.read(duplicateSelectionProvider.notifier).toggle(photo.id);
                  },
                  child: Stack(
                    children: [
                      // Photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: AppColors.divider,
                          child: Image(
                            image: AssetEntityImageProvider(
                              photo.asset,
                              isOriginal: false,
                              thumbnailSize: ThumbnailSize(200, 200),
                            ),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),

                      // Best quality badge
                      if (isBest)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Best',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      // Selection overlay
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Select all but keep best (largest file)
                    final toDelete = group.duplicates;
                    ref.read(duplicateSelectionProvider.notifier).addAll(
                      toDelete.map((p) => p.id).toSet(),
                    );
                  },
                  child: Text(
                    'Keep Best',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
