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
        backgroundColor: AppColors.snow,
        appBar: AppBar(
          backgroundColor: AppColors.snow,
          elevation: 0,
          toolbarHeight: 70,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tools',
                style: TextStyle(
                  color: AppColors.textPrimary,
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
                      icon: Icons.content_copy_rounded,
                      title: 'Find Duplicates',
                      subtitle: 'Remove copies',
                      gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      onTap: () => context.push('/duplicates'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Smart Collections',
                      subtitle: 'Auto-organized',
                      gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                      onTap: () => context.push('/smart-collections'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Compression Section
              Text('COMPRESSION', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.photo_size_select_large_rounded,
                      title: 'Compress Photos',
                      subtitle: 'Reduce file size',
                      gradientColors: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                      onTap: () => context.push('/compress-photos'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.video_settings_rounded,
                      title: 'Compress Videos',
                      subtitle: 'Smaller videos',
                      gradientColors: const [Color(0xFFFA709A), Color(0xFFFEE140)],
                      onTap: () => context.push('/compress-videos'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Conversion Section
              Text('CONVERSION', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.picture_as_pdf_rounded,
                      title: 'Create PDF',
                      subtitle: 'From photos',
                      gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      onTap: () => context.push('/create-pdf'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.burst_mode_rounded,
                      title: 'Video Frames',
                      subtitle: 'Extract images',
                      gradientColors: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      onTap: () => context.push('/video-frames'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Storage Section
              Text('STORAGE', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.storage_rounded,
                      title: 'Storage Stats',
                      subtitle: 'Usage overview',
                      gradientColors: const [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                      onTap: () => context.push('/storage-stats'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.delete_sweep_rounded,
                      title: 'Recently Deleted',
                      subtitle: '30-day recovery',
                      gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                      onTap: () => context.push('/recently-deleted'),
                    ),
                  ),
                ],
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
          color: AppColors.cardBackground,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
