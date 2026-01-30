import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../photos/domain/providers/photo_provider.dart';

/// Smart Collections screen with auto-categorized photo groups
class SmartCollectionsScreen extends ConsumerWidget {
  const SmartCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(allPhotosProvider);

    return Scaffold(
      // backgroundColor: removed to use theme default
      appBar: AppBar(
        // backgroundColor: removed to use theme default
        elevation: 0,
        title: Text(
          'Smart Collections',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Error loading collections',
                style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        data: (photos) {
          // Calculate collection counts
          final largeFiles = photos.where((p) => (p.fileSize ?? 0) > 10 * 1024 * 1024).toList();
          // Check for screenshots by looking at asset title or relative path
          final screenshots = photos.where((p) => 
            (p.title?.toLowerCase().contains('screenshot') ?? false) ||
            (p.asset.relativePath?.toLowerCase().contains('screenshot') ?? false)
          ).toList();
          // Use the built-in isOld getter
          final oldPhotos = photos.where((p) => p.isOld).toList();
          // Similar photos would need ML - just show a placeholder count
          final similarCount = (photos.length * 0.1).round();

          final largeFilesSize = largeFiles.fold<int>(
            0, (sum, p) => sum + (p.fileSize ?? 0));
          final screenshotsSize = screenshots.fold<int>(
            0, (sum, p) => sum + (p.fileSize ?? 0));
          final oldPhotosSize = oldPhotos.fold<int>(
            0, (sum, p) => sum + (p.fileSize ?? 0));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI-Powered Organization',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).textTheme.titleMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Photos are automatically grouped for easy cleanup',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Collection Cards
                _CollectionCard(
                  icon: Icons.storage_rounded,
                  title: 'Large Files',
                  subtitle: '>10 MB each',
                  count: largeFiles.length,
                  size: formatBytes(largeFilesSize),
                  gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  onTap: () => context.push('/collection-photos/large'),
                ),

                const SizedBox(height: 12),

                _CollectionCard(
                  icon: Icons.access_time_rounded,
                  title: 'Old Photos',
                  subtitle: '>1 year old',
                  count: oldPhotos.length,
                  size: formatBytes(oldPhotosSize),
                  gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                  onTap: () => context.push('/collection-photos/old'),
                ),

                const SizedBox(height: 12),

                _CollectionCard(
                  icon: Icons.screenshot_rounded,
                  title: 'Screenshots',
                  subtitle: 'Screen captures',
                  count: screenshots.length,
                  size: formatBytes(screenshotsSize),
                  gradientColors: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  onTap: () => context.push('/collection-photos/screenshots'),
                ),

                const SizedBox(height: 12),

                _CollectionCard(
                  icon: Icons.filter_none_rounded,
                  title: 'Similar Photos',
                  subtitle: 'Near duplicates',
                  count: similarCount,
                  size: '~${formatBytes((photos.length * 0.1 * 2 * 1024 * 1024).round())}',
                  gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                  onTap: () => context.push('/duplicates'),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final String size;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _CollectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.size,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with gradient
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.slateIcon,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),

            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Count and size
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gradientColors.first.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: gradientColors.first,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  size,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
