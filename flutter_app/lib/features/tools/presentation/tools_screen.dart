import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/models/tool_item.dart';
import 'widgets/tool_card.dart';

/// Tools screen with photo tools and utilities
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static final List<ToolCategory> _categories = [
    ToolCategory(
      title: 'Cleanup',
      tools: [
        ToolItem(
          title: 'Find Duplicates',
          subtitle: 'Detect and remove duplicate photos',
          icon: Icons.content_copy,
          gradient: AppColors.gradientPurple,
          route: '/duplicates',
        ),
        ToolItem(
          title: 'Smart Collections',
          subtitle: 'Auto-categorized photo groups',
          icon: Icons.auto_awesome,
          gradient: AppColors.gradientBlue,
          route: '/smart-collections',
        ),
      ],
    ),
    ToolCategory(
      title: 'Compression',
      tools: [
        ToolItem(
          title: 'Compress Photos',
          subtitle: 'Reduce image file sizes',
          icon: Icons.compress,
          gradient: AppColors.gradientOrange,
          route: '/compress',
        ),
        ToolItem(
          title: 'Compress Videos',
          subtitle: 'Reduce video file sizes',
          icon: Icons.video_settings,
          gradient: AppColors.gradientRed,
          route: '/compress-videos',
        ),
      ],
    ),
    ToolCategory(
      title: 'Conversion',
      tools: [
        ToolItem(
          title: 'Create PDF',
          subtitle: 'Combine photos into PDF',
          icon: Icons.picture_as_pdf,
          gradient: AppColors.gradientTeal,
          route: '/create-pdf',
        ),
        ToolItem(
          title: 'Video Frames',
          subtitle: 'Extract frames from videos',
          icon: Icons.burst_mode,
          gradient: AppColors.gradientPink,
          route: '/video-frames',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tools'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, categoryIndex) {
          final category = _categories[categoryIndex];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categoryIndex > 0) const SizedBox(height: 24),

              // Category header
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  category.title.toUpperCase(),
                  style: AppTextStyles.sectionHeader,
                ),
              ),

              // Tools grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: category.tools.length,
                itemBuilder: (context, toolIndex) {
                  final tool = category.tools[toolIndex];

                  return ToolCard(
                    title: tool.title,
                    subtitle: tool.subtitle,
                    icon: tool.icon,
                    gradient: tool.gradient,
                    onTap: () {
                      context.push(tool.route);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
