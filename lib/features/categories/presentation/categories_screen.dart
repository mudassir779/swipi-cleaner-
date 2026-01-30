import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_gradient_button.dart';
import '../../../core/widgets/stagger_in.dart';
import '../domain/providers/categories_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Categories'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Select All'),
          ),
        ],
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load categories.\n$e',
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (items) {
            final total = items.fold<int>(0, (sum, i) => sum + i.count);

            return Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return StaggerIn(
                      delay: Duration(milliseconds: 40 + (index * 40)),
                      child: _CategoryCard(
                        title: item.title,
                        countLabel: item.count == 1 ? '1 item' : '${item.count} items',
                        icon: item.icon,
                        accent: item.accent,
                        previews: item.previews,
                        isEmpty: item.count == 0,
                        comingSoon: item.comingSoon,
                        onTap: item.comingSoon
                            ? null
                            : () {
                                if (item.id == 'screenshots') {
                                  context.push('/swipe-review?filter=screenshots');
                                } else if (item.id == 'large_videos') {
                                  context.push('/swipe-review?filter=large_videos');
                                }
                              },
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total items',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$total',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryGradientButton(
                            colors: const [Color(0xFF111827), Color(0xFF0B1220)],
                            onPressed: total == 0 ? null : () => context.push('/swipe-review?filter=random'),
                            child: const Text(
                              'Review All',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
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
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String countLabel;
  final IconData icon;
  final Color accent;
  final List<AssetEntity> previews;
  final bool isEmpty;
  final bool comingSoon;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.title,
    required this.countLabel,
    required this.icon,
    required this.accent,
    required this.previews,
    required this.isEmpty,
    required this.comingSoon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Opacity(
            opacity: isEmpty ? 0.6 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                    const Spacer(),
                    if (comingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Text(
                          'Soon',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEmpty ? 'All clean!' : countLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: isEmpty || previews.isEmpty
                        ? Container(
                            color: AppColors.surface,
                            child: Center(
                              child: Icon(
                                Icons.check_circle_outline,
                                color: accent.withValues(alpha: 0.9),
                                size: 34,
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              childAspectRatio: 1,
                            ),
                            itemCount: previews.length.clamp(0, 4),
                            itemBuilder: (context, index) {
                              final asset = previews[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  image: AssetEntityImageProvider(
                                    asset,
                                    isOriginal: false,
                                    thumbnailSize: ThumbnailSize(160, 160),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

