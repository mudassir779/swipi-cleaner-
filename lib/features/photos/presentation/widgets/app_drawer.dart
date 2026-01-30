import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/premium_ui.dart';
import 'dart:math' as math;

/// App navigation drawer - Apple-style minimal design
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = math.min(MediaQuery.of(context).size.width * 0.75, 400.0);
    const dividerColor = Color(0xFFF0F0F0);

    return SizedBox(
      width: width,
      child: Drawer(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Swipe to Clean\nStorage',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1, color: dividerColor),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _MenuItemWidget(
                        icon: Icons.content_copy_outlined,
                        label: 'Find Duplicates',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/duplicates');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.photo_size_select_large_rounded,
                        label: 'Compress Photos',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/compress-photos');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.video_settings_rounded,
                        label: 'Compress Videos',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/compress-videos');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.picture_as_pdf_rounded,
                        label: 'Create PDF',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/create-pdf');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.burst_mode_rounded,
                        label: 'Video Frames',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/video-frames');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.grid_view_rounded,
                        label: 'Categories',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/categories');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.bar_chart_rounded,
                        label: 'Storage Stats',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/storage-stats');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/settings');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Upgrade to Premium',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/premium');
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text(
                                'Help & Support',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              content: const Text(
                                'Need help? We\'re here for you!\n\n'
                                'Email: support@swipetoclean.app\n'
                                'Website: swipetoclean.app',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24, color: dividerColor),
                      _MenuItemWidget(
                        icon: Icons.info_outline_rounded,
                        label: 'About',
                        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text(
                                'About',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              content: const Text(
                                'Swipe to Clean Storage\n\n'
                                'The fastest way to clean your photo library.\n\n'
                                'Version 1.0.0\n'
                                '© 2026 Swipe to Clean',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Version Footer
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}

class _MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MenuItemWidget({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              PremiumIcon(
                icon: icon,
                gradientColors: gradientColors,
                size: 20,
                backgroundSize: 44,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              GradientIcon(
                icon: Icons.chevron_right,
                colors: gradientColors,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
