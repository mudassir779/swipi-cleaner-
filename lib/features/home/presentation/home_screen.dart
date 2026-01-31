import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/main_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_loading.dart';
import '../../photos/domain/providers/delete_queue_provider.dart';
import '../../photos/domain/providers/month_photos_provider.dart';
import '../../photos/domain/providers/photo_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/stats_card.dart';

/// Home dashboard screen with statistics and quick actions
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final List<AnimationController> _cardControllers;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 0-3 = stats cards, 4-7 = quick action cards
    _cardControllers = List.generate(
      8,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _scaleController.forward();

    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(photoVideoStatsProvider);
    final deleteQueue = ref.watch(deleteQueueProvider);
    final todayPhotosAsync = ref.watch(todayPhotosProvider);

    return MainScaffold(
      currentIndex: 0,
      child: Scaffold(
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(photoVideoStatsProvider);
            ref.invalidate(todayPhotosProvider);
          },
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildHeader(),
                      const SizedBox(height: 30),
                      statsAsync.when(
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
                      const SizedBox(height: 35),
                      _buildSectionTitle('QUICK ACTIONS'),
                      const SizedBox(height: 15),
                      _buildQuickActionsGrid(),
                      const SizedBox(height: 30),
                      _buildStorageOverview(),
                      const SizedBox(height: 20),
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _scaleController,
          curve: Curves.easeOutBack,
        ),
      ),
      child: const HomeHeader(),
    );
  }

  Widget _animatedCardEntry({required int index, required Widget child}) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardControllers[index],
          curve: Curves.easeOutBack,
        ),
      ),
      child: FadeTransition(
        opacity: _cardControllers[index],
        child: child,
      ),
    );
  }

  Widget _buildStatsGrid(int photos, int videos, int today, int deleteQueueCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.25,
      children: [
        _animatedCardEntry(
          index: 0,
          child: StatsCard(
            label: 'Photos',
            value: '$photos',
            icon: Icons.photo_library_rounded,
            gradientColors: const [Color(0xFF4A9EFF), Color(0xFF6DB3FF)],
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSnackBar('Opening Photos...');
            },
          ),
        ),
        _animatedCardEntry(
          index: 1,
          child: StatsCard(
            label: 'Videos',
            value: '$videos',
            icon: Icons.videocam_rounded,
            gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSnackBar('Opening Videos...');
            },
          ),
        ),
        _animatedCardEntry(
          index: 2,
          child: StatsCard(
            label: 'Today',
            value: '$today',
            icon: Icons.calendar_today_rounded,
            gradientColors: const [Color(0xFFFF8A3D), Color(0xFFFFAA6C)],
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSnackBar('Opening Today...');
            },
          ),
        ),
        _animatedCardEntry(
          index: 3,
          child: StatsCard(
            label: 'To Delete',
            value: '$deleteQueueCount',
            icon: Icons.delete_rounded,
            gradientColors: const [Color(0xFFFF5757), Color(0xFFFF7B7B)],
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSnackBar('Opening To Delete...');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF86868B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _animatedCardEntry(
                index: 4,
                child: QuickActionCard(
                  title: 'Swipe Review',
                  subtitle: 'Clean photos fast',
                  icon: Icons.swipe_rounded,
                  gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/swipe-review');
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _animatedCardEntry(
                index: 5,
                child: QuickActionCard(
                  title: 'Find Duplicates',
                  subtitle: 'Remove copies',
                  icon: Icons.content_copy_rounded,
                  gradientColors: const [Color(0xFF6B8CFF), Color(0xFF8FA5FF)],
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/duplicates');
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _animatedCardEntry(
                index: 6,
                child: QuickActionCard(
                  title: 'Smart Collections',
                  subtitle: 'Auto-organized',
                  icon: Icons.auto_awesome_rounded,
                  gradientColors: const [Color(0xFF26D9A0), Color(0xFF5AE7BB)],
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/smart-collections');
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _animatedCardEntry(
                index: 7,
                child: QuickActionCard(
                  title: 'Compress Photos',
                  subtitle: 'Save space',
                  icon: Icons.compress_rounded,
                  gradientColors: const [Color(0xFFFF5EC0), Color(0xFFFF85D5)],
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/compress-photos');
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorageOverview() {
    return _StorageOverviewCard(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/storage-stats');
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StorageOverviewCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StorageOverviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storage_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Storage Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
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
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.25,
      children: List.generate(
        4,
        (_) => const CardSkeleton(
          height: 130,
          borderRadius: BorderRadius.all(Radius.circular(20)),
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
