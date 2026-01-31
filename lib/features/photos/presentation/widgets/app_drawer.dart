import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'dart:math' as math;

/// App navigation drawer - Animated Apple-style design
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation when drawer opens
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.of(context).size.width * 0.75, 400.0);
    const dividerColor = Color(0xFFF0F0F0);

    final menuItems = _buildMenuItems(context, dividerColor);

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
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color(0xFF1A1A25).withValues(alpha: 0.95),
                          const Color(0xFF0F0F17).withValues(alpha: 0.95),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.85),
                        ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Animated Header
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_slideAnimation.value, 0),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: AppColors.gradientPrimary,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Swipe to Clean',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Storage',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _AnimatedCloseButton(
                              animation: _fadeAnimation,
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),

                    // Animated Menu Items
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          return _AnimatedMenuItem(
                            animation: _animationController,
                            index: index,
                            child: menuItems[index],
                          );
                        },
                      ),
                    ),

                    // Animated Version Footer
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        );
                      },
                      child: const Padding(
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

  List<Widget> _buildMenuItems(BuildContext context, Color dividerColor) {
    final items = <_MenuItemData>[

      _MenuItemData(
        icon: Icons.video_settings_rounded,
        label: 'Compress Videos',
        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
        route: '/compress-videos',
      ),
      _MenuItemData(
        icon: Icons.picture_as_pdf_rounded,
        label: 'Create PDF',
        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
        route: '/create-pdf',
      ),
      _MenuItemData(
        icon: Icons.burst_mode_rounded,
        label: 'Video Frames',
        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
        route: '/video-frames',
      ),
      _MenuItemData(
        icon: Icons.grid_view_rounded,
        label: 'Categories',
        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
        route: '/categories',
      ),
      _MenuItemData(
        icon: Icons.bar_chart_rounded,
        label: 'Storage Stats',
        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
        route: '/storage-stats',
      ),
      _MenuItemData(
        icon: Icons.workspace_premium_outlined,
        label: 'Upgrade to Premium',
        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
        route: '/premium',
        isPremium: true,
      ),
      _MenuItemData(
        icon: Icons.settings_outlined,
        label: 'Settings',
        gradientColors: const [Color(0xFF718096), Color(0xFFA0AEC0)],
        route: '/settings',
      ),
    ];

    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(
        _MenuItemWidget(
          icon: item.icon,
          label: item.label,
          gradientColors: item.gradientColors,
          isPremium: item.isPremium,
          onTap: () {
            Navigator.pop(context);
            context.push(item.route);
          },
        ),
      );
      if (i < items.length - 1) {
        widgets.add(Divider(height: 1, indent: 24, endIndent: 24, color: Theme.of(context).dividerColor));
      }
    }

    // Add Help & About section
    widgets.add(const SizedBox(height: 16));
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'SUPPORT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodySmall?.color,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
    widgets.add(const SizedBox(height: 8));
    widgets.add(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    );
    widgets.add(Divider(height: 1, indent: 24, endIndent: 24, color: Theme.of(context).dividerColor));
    widgets.add(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    );

    return widgets;
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final String route;
  final bool isPremium;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.route,
    this.isPremium = false,
  });
}

class _AnimatedMenuItem extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Widget child;

  const _AnimatedMenuItem({
    required this.animation,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Enhanced staggered animation with more noticeable delays
    final delay = (index * 0.06).clamp(0.0, 0.45);
    final endTime = math.min(1.0, 0.55 + delay);

    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay,
          endTime,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay,
          endTime,
          curve: Curves.easeOut,
        ),
      ),
    );

    final scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay,
          endTime,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(slideAnimation.value.dx * 80, 0),
          child: Transform.scale(
            scale: scaleAnimation.value,
            alignment: Alignment.centerLeft,
            child: Opacity(
              opacity: fadeAnimation.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedCloseButton extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onTap;

  const _AnimatedCloseButton({
    required this.animation,
    required this.onTap,
  });

  @override
  State<_AnimatedCloseButton> createState() => _AnimatedCloseButtonState();
}

class _AnimatedCloseButtonState extends State<_AnimatedCloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (widget.animation.value * 0.2),
          child: Opacity(
            opacity: widget.animation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isPressed 
                ? (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade200)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Icon(
            Icons.close,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _MenuItemWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isPremium;

  const _MenuItemWidget({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  State<_MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<_MenuItemWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _isPressed 
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors.map(
                    (c) => c.withValues(alpha: 0.15),
                  ).toList(),
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.gradientColors.first.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: widget.gradientColors,
                ).createShader(bounds),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(4),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: widget.gradientColors,
                ).createShader(bounds),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
