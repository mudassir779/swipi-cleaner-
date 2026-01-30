import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';

import 'onboarding_effects.dart';

/// Third onboarding hero that matches the v0 (React/Tailwind) Smart Collections design:
/// blue/indigo gradient background, glowing ring, layered cards effect, and stacking animation.
class SmartCollectionsOnboardingHero extends StatefulWidget {
  final String title;
  final String description;

  const SmartCollectionsOnboardingHero({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<SmartCollectionsOnboardingHero> createState() => _SmartCollectionsOnboardingHeroState();
}

class _SmartCollectionsOnboardingHeroState extends State<SmartCollectionsOnboardingHero>
    with TickerProviderStateMixin {
  // Background (Tailwind-ish)
  static const Color _blue50 = Color(0xFFEFF6FF);
  static const Color _indigo50 = Color(0xFFEEF2FF);

  // Glow + icon gradients
  static const Color _blue300 = Color(0xFF93C5FD);
  static const Color _indigo400 = Color(0xFF818CF8);
  static const Color _blue500 = Color(0xFF3B82F6);
  static const Color _indigo600 = Color(0xFF4F46E5);

  // Text colors
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // Stacking animation: 0..8..0 (smooth)
  late final AnimationController _stackController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _entranceController,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _stackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue50, Colors.white, _indigo50],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FadeTransition(
              opacity: _opacity,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconHero(),
                    const SizedBox(height: 48),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          color: _textSecondary,
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

  Widget _buildIconHero() {
    return SizedBox(
      height: 220,
      width: 220,
      child: AnimatedBuilder(
        animation: _stackController,
        builder: (context, child) {
          final t = _stackController.value; // 0..1
          final stackOffset = lerpDouble(0, 8, t) ?? 0;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Opacity(
                opacity: 0.30,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_blue300, _indigo400],
                      ),
                    ),
                  ),
                ),
              ),

              // Decorative layered cards (behind main circle)
              Transform.translate(
                offset: Offset(0, stackOffset * 2),
                child: Transform.rotate(
                  angle: -0.1047, // -6deg
                  child: Container(
                    width: 128,
                    height: 96,
                    decoration: BoxDecoration(
                      color: _blue300.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, stackOffset * 1.5),
                child: Transform.rotate(
                  angle: 0.1047, // +6deg
                  child: Container(
                    width: 128,
                    height: 96,
                    decoration: BoxDecoration(
                      color: _blue300.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Main icon circle
              Container(
                padding: const EdgeInsets.all(56),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_blue500, _indigo600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -stackOffset),
                      child: const Icon(
                        Icons.layers_outlined,
                        size: 84,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Decorative dots
              const Positioned(
                top: 14,
                right: 22,
                child: OnboardingPingDot(color: _blue300),
              ),
              const Positioned(
                bottom: 6,
                left: 10,
                child: OnboardingPulseDot(color: Color(0xFFA5B4FC)), // indigo-300-ish
              ),
            ],
          );
        },
      ),
    );
  }
}

