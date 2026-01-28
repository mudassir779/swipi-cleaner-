import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// App navigation drawer - Apple-style minimal design
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Apple-style header (large, minimal)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Text(
                'Swipe to Clean Storage',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Menu items (minimal, clean)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    title: 'Find Duplicates',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/duplicates');
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildDrawerItem(
                    context,
                    title: 'Storage Stats',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/storage-stats');
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildDrawerItem(
                    context,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Version 1.0.0',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a minimal drawer item (Apple-style)
  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
