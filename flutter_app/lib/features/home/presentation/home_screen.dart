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
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Clean Gallery',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
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
              Text(
                'Dashboard',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quick overview of your photo library',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                            iconColor: AppColors.primary,
                            onTap: () => context.go('/photos'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            label: 'Videos',
                            value: stats.totalVideos.toString(),
                            icon: Icons.video_library,
                            iconColor: AppColors.purple,
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
                            iconColor: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            label: 'To Delete',
                            value: stats.deleteQueueCount.toString(),
                            icon: Icons.delete_outline,
                            iconColor: AppColors.error,
                            onTap: stats.deleteQueueCount > 0
                                ? () {
                                    context.go('/confirm-delete');
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
              Text(
                'Quick Actions',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
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
