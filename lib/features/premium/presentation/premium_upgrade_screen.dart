import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../core/theme/app_colors.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen>
    with TickerProviderStateMixin {
  _Plan _selected = _Plan.yearly;
  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_bgController.value * 2 * math.pi),
                      math.sin(_bgController.value * 2 * math.pi),
                    ),
                    end: Alignment(
                      -math.cos(_bgController.value * 2 * math.pi),
                      -math.sin(_bgController.value * 2 * math.pi),
                    ),
                    colors: const [
                      Color(0xFFE0F2FE), // sky-100
                      Color(0xFFF0F9FF), // sky-50
                      Color(0xFFE0F2FE), // sky-100
                      Color(0xFFBAE6FD), // sky-200
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              );
            },
          ),

          // Decorative circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    const Color(0xFF38BDF8).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      _AnimatedBackButton(onTap: () => context.pop()),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium_rounded, 
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        children: [
                          // Hero Section
                          _buildHeroSection(),
                          const SizedBox(height: 28),

                          // Features Grid
                          _buildFeaturesSection(),
                          const SizedBox(height: 28),

                          // Pricing Cards
                          _buildPricingSection(),
                          const SizedBox(height: 24),

                          // CTA Button
                          _buildCTAButton(),
                          const SizedBox(height: 16),

                          // Trust indicators
                          _buildTrustIndicators(),
                          const SizedBox(height: 16),

                          // Footer links
                          _buildFooterLinks(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Crown icon with glow
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.gradientPrimary,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.diamond_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: [
              AppColors.primary,
              const Color(0xFF0EA5E9),
              AppColors.primary,
            ],
          ).createShader(rect),
          child: const Text(
            'Unlock Premium',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get unlimited access to all features',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientPrimary),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Premium Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._features.asMap().entries.map((e) {
          return _AnimatedFeatureCard(
            index: e.key,
            icon: e.value.icon,
            title: e.value.title,
            description: e.value.description,
            gradient: e.value.gradient,
          );
        }),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ModernPriceCard(
                title: 'Monthly',
                price: r'$4.99',
                period: '/month',
                selected: _selected == _Plan.monthly,
                onTap: () => setState(() => _selected = _Plan.monthly),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernPriceCard(
                title: 'Yearly',
                price: r'$39.99',
                period: '/year',
                selected: _selected == _Plan.yearly,
                badge: 'SAVE 33%',
                isPrimary: true,
                onTap: () => setState(() => _selected = _Plan.yearly),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases not wired yet (UI only).')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientPrimary,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Start 7-Day Free Trial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selected == _Plan.yearly
                  ? 'Then \$39.99/year'
                  : 'Then \$4.99/month',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TrustBadge(icon: Icons.star_rounded, text: '4.9 Rating'),
        const SizedBox(width: 16),
        _TrustBadge(icon: Icons.lock_rounded, text: 'Secure'),
        const SizedBox(width: 16),
        _TrustBadge(icon: Icons.refresh_rounded, text: 'Cancel Anytime'),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Restore purchases coming soon')),
            );
          },
          child: Text(
            'Restore Purchases',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms & Privacy coming soon')),
            );
          },
          child: Text(
            'Terms & Privacy',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

enum _Plan { monthly, yearly }

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

const _features = <_Feature>[
  _Feature(
    icon: Icons.all_inclusive_rounded,
    title: 'Unlimited Scans',
    description: 'Scan your entire library anytime',
    gradient: [Color(0xFF87CEEB), Color(0xFF5FB6E0)],
  ),
  _Feature(
    icon: Icons.auto_awesome_rounded,
    title: 'AI-Powered Sorting',
    description: 'Smart organization with advanced AI',
    gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
  ),
  _Feature(
    icon: Icons.cloud_rounded,
    title: 'Cloud Backup',
    description: 'Secure backup of all your photos',
    gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  ),
  _Feature(
    icon: Icons.bolt_rounded,
    title: 'Priority Support',
    description: 'Get help within 24 hours',
    gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
  ),
  _Feature(
    icon: Icons.visibility_off_rounded,
    title: 'Ad-Free Experience',
    description: 'Clean interface without distractions',
    gradient: [Color(0xFF10B981), Color(0xFF059669)],
  ),
];

class _AnimatedFeatureCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _AnimatedFeatureCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: 100 + widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withValues(alpha: 0.1),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.gradient.first.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: widget.gradient.first,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernPriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool selected;
  final String? badge;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ModernPriceCard({
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.badge,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isPrimary && selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.gradientPrimary,
                )
              : null,
          color: isPrimary && selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (isPrimary ? Colors.transparent : AppColors.primary)
                : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: isPrimary
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isPrimary && selected
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (selected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isPrimary && selected
                          ? Colors.white
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: isPrimary && selected
                          ? AppColors.primary
                          : Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            if (badge != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPrimary && selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: isPrimary && selected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isPrimary && selected
                        ? Colors.white
                        : AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    period,
                    style: TextStyle(
                      color: isPrimary && selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedBackButton({required this.onTap});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}
