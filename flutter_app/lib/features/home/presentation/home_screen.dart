import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/providers/home_provider.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/stats_card.dart';

/// Home dashboard screen with statistics and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);
    final quickActions = ref.watch(quickActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clean Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Dashboard',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              const Text(
                'Quick overview of your photo library',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              statsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading stats: $error',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ),
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            label: 'Photos',
                            value: stats.totalPhotos.toString(),
                            icon: Icons.photo_library,
                            backgroundColor: AppColors.statsPhotos,
                            onTap: () => context.go('/photos'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            label: 'Videos',
                            value: stats.totalVideos.toString(),
                            icon: Icons.video_library,
                            backgroundColor: AppColors.statsVideos,
                            onTap: () => context.go('/photos'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            label: 'Today',
                            value: stats.todayPhotos.toString(),
                            icon: Icons.today,
                            backgroundColor: AppColors.statsToday,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            label: 'To Delete',
                            value: stats.deleteQueueCount.toString(),
                            icon: Icons.delete_outline,
                            backgroundColor: AppColors.statsToDelete,
                            onTap: stats.deleteQueueCount > 0
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Delete queue coming soon'),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions Header
              const Text(
                'QUICK ACTIONS',
                style: AppTextStyles.sectionHeader,
              ),
              const SizedBox(height: 16),

              // Quick Action Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: quickActions.length,
                itemBuilder: (context, index) {
                  final action = quickActions[index];
                  return QuickActionCard(
                    title: action.title,
                    subtitle: action.subtitle,
                    gradient: action.gradient,
                    icon: action.icon,
                    onTap: () {
                      context.push(action.route);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
