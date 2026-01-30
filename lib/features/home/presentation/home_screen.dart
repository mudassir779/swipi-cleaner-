import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/skeleton_loading.dart';
import '../../photos/domain/providers/photo_provider.dart';
import '../../photos/domain/providers/delete_queue_provider.dart';
import '../../photos/domain/providers/month_photos_provider.dart';
import '../../../app/main_scaffold.dart';

/// Home dashboard screen with statistics and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(allPhotosProvider);
    final deleteQueue = ref.watch(deleteQueueProvider);
    final todayPhotosAsync = ref.watch(todayPhotosProvider);

    return MainScaffold(
      currentIndex: 0,
      child: Scaffold(
        // backgroundColor: removed to use theme default
        appBar: AppBar(
          // backgroundColor: removed to use theme default
          elevation: 0,
          toolbarHeight: 70,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Swipe to Clean',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24, // Slightly smaller to fit better
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(left: 52), // Align with text start
                child: Text(
                  'Free up space with a swipe',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),

        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(allPhotosProvider);
            ref.invalidate(todayPhotosProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                photosAsync.when(
                  loading: () => const _StatsGridSkeleton(),
                  error: (e, _) => _buildStatsGrid(0, 0, 0, deleteQueue.length),
                  data: (photos) {
                    final photoCount = photos.where((p) => p.asset.type == AssetType.image).length;
                    final videoCount = photos.where((p) => p.asset.type == AssetType.video).length;
                    final todayCount = todayPhotosAsync.maybeWhen(
                      data: (t) => t.length,
                      orElse: () => 0,
                    );
                    return _buildStatsGrid(
                      photoCount, 
                      videoCount, 
                      todayCount, 
                      deleteQueue.length,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Quick Actions Section
                Text(
                  'QUICK ACTIONS',
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: 12),

                // Quick Action Cards Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _QuickActionCard(
                      icon: Icons.swipe,
                      title: 'Swipe Review',
                      subtitle: 'Clean photos fast',
                      gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      onTap: () => context.push('/swipe-review'),
                    ),
                    _QuickActionCard(
                      icon: Icons.content_copy,
                      title: 'Find Duplicates',
                      subtitle: 'Remove copies',
                      gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      onTap: () => context.push('/duplicates'),
                    ),
                    _QuickActionCard(
                      icon: Icons.auto_awesome,
                      title: 'Smart Collections',
                      subtitle: 'Auto-organized',
                      gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                      onTap: () => context.push('/smart-collections'),
                    ),
                    _QuickActionCard(
                      icon: Icons.compress,
                      title: 'Compress Photos',
                      subtitle: 'Save space',
                      gradientColors: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                      onTap: () => context.push('/compress-photos'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Storage Overview Card
                _StorageOverviewCard(
                  onTap: () => context.push('/storage-stats'),
                ),

                const SizedBox(height: 24),

                // Delete Queue Banner (if items present)
                if (deleteQueue.isNotEmpty)
                  _DeleteQueueBanner(
                    count: deleteQueue.length,
                    onTap: () => context.push('/confirm-delete'),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int photos, int videos, int today, int deleteQueue) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.75,
      children: [
        _StatCard(
          icon: Icons.photo_library,
          value: '$photos',
          label: 'Photos',
          color: const Color(0xFF3B82F6),
        ),
        _StatCard(
          icon: Icons.videocam,
          value: '$videos',
          label: 'Videos',
          color: const Color(0xFF3B82F6),
        ),
        _StatCard(
          icon: Icons.today,
          value: '$today',
          label: 'Today',
          color: const Color(0xFFF97316),
        ),
        _StatCard(
          icon: Icons.delete_outline,
          value: '$deleteQueue',
          label: 'To Delete',
          color: AppColors.red,
        ),
      ],
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: List.generate(4, (_) => const CardSkeleton(
        height: 60,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      )),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.slateIcon,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.slateIcon,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            Column(
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _StorageOverviewCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StorageOverviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storage_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Storage Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to see detailed breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteQueueBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _DeleteQueueBanner({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF416C).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_sweep,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count items ready to delete',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to review and confirm',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
