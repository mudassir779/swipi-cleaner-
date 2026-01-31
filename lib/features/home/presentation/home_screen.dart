import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/skeleton_loading.dart';
import '../../../core/widgets/animations.dart';
import '../../photos/domain/providers/photo_provider.dart';
import '../../photos/domain/providers/delete_queue_provider.dart';
import '../../photos/domain/providers/month_photos_provider.dart';
import '../../../app/main_scaffold.dart';

/// Home dashboard screen with statistics and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use fast stats provider for instant photo/video counts
    final statsAsync = ref.watch(photoVideoStatsProvider);
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
          title: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Column(
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
                      Text(
                        'Swipe to Clean',
                        style: TextStyle(
                          color: theme.textTheme.titleLarge?.color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Text(
                      'Free up space with a swipe',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(photoVideoStatsProvider);
            ref.invalidate(todayPhotosProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards - now using fast stats provider with animation
                FadeSlideIn(
                  delay: const Duration(milliseconds: 0),
                  child: statsAsync.when(
                    loading: () => const _StatsGridSkeleton(),
                    error: (e, _) => _buildStatsGrid(0, 0, 0, deleteQueue.length),
                    data: (stats) {
                      final photoCount = stats['photos'] ?? 0;
                      final videoCount = stats['videos'] ?? 0;
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
                ),

                const SizedBox(height: 24),

                // Quick Actions Section with animation
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'QUICK ACTIONS',
                    style: AppTextStyles.sectionHeader,
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Action Cards Grid with animation
                FadeSlideIn(
                  delay: const Duration(milliseconds: 150),
                  child: GridView.count(
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
                        gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
                        onTap: () => context.push('/swipe-review'),
                      ),
                      _QuickActionCard(
                        icon: Icons.content_copy,
                        title: 'Find Duplicates',
                        subtitle: 'Remove copies',
                        gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
                        onTap: () => context.push('/duplicates'),
                      ),
                      _QuickActionCard(
                        icon: Icons.auto_awesome,
                        title: 'Smart Collections',
                        subtitle: 'Auto-organized',
                        gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
                        onTap: () => context.push('/smart-collections'),
                      ),
                      _QuickActionCard(
                        icon: Icons.compress,
                        title: 'Compress Photos',
                        subtitle: 'Save space',
                        gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
                        onTap: () => context.push('/compress-photos'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Storage Overview Card with animation
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: _StorageOverviewCard(
                    onTap: () => context.push('/storage-stats'),
                  ),
                ),

                const SizedBox(height: 24),

                // Delete Queue Banner (if items present) with animation
                if (deleteQueue.isNotEmpty)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: _DeleteQueueBanner(
                      count: deleteQueue.length,
                      onTap: () => context.push('/confirm-delete'),
                    ),
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
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Icons.photo_library_rounded,
          value: '$photos',
          label: 'Photos',
          color: const Color(0xFF71C4D9),
          gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
        ),
        _StatCard(
          icon: Icons.videocam_rounded,
          value: '$videos',
          label: 'Videos',
          color: const Color(0xFF71C4D9),
          gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
        ),
        _StatCard(
          icon: Icons.today_rounded,
          value: '$today',
          label: 'Today',
          color: const Color(0xFF71C4D9),
          gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
        ),
        _StatCard(
          icon: Icons.delete_sweep_rounded,
          value: '$deleteQueue',
          label: 'To Delete',
          color: const Color(0xFF71C4D9),
          gradientColors: const [Color(0xFF71C4D9), Color(0xFF5BB8D0)],
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

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final List<Color>? gradientColors;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.gradientColors,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradientColors ?? [widget.color, widget.color.withValues(alpha: 0.7)];
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Gradient icon container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
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
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
