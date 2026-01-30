import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../app/main_scaffold.dart';

/// Tools tab screen with categorized tool cards
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 2,
      child: Scaffold(
        // backgroundColor: removed to use theme default
        appBar: AppBar(
          // backgroundColor: removed to use theme default
          elevation: 0,
          toolbarHeight: 70,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tools',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Powerful utilities for your library',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cleanup Section
              Text('CLEANUP', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Smart Collections',
                      subtitle: 'Auto-organized',
                      gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                      onTap: () => context.push('/smart-collections'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Social Media Cleaner',
                      subtitle: 'WhatsApp & Telegram',
                      gradientColors: const [Color(0xFF25D366), Color(0xFF0088CC)],
                      onTap: () => context.push('/social-media-cleaner'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Storage Section
              Text('STORAGE', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.delete_sweep_rounded,
                title: 'Recently Deleted',
                subtitle: '30-day recovery',
                gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                onTap: () => context.push('/recently-deleted'),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ToolCard({
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
        height: 140, // Slightly taller to accommodate new design
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
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
