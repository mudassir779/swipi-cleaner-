import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'onboarding_effects.dart';

/// Second onboarding hero that matches the v0 (React/Tailwind) design:
/// amber/orange gradient background, glowing ring, and a swipe (translateX) animation.
class SwipeToCleanOnboardingHero extends StatefulWidget {
  final String title;
  final String description;

  const SwipeToCleanOnboardingHero({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<SwipeToCleanOnboardingHero> createState() => _SwipeToCleanOnboardingHeroState();
}

class _SwipeToCleanOnboardingHeroState extends State<SwipeToCleanOnboardingHero>
    with TickerProviderStateMixin {
  // Background
  static const Color _amber50 = Color(0xFFFFFBEB);
  static const Color _orange50 = Color(0xFFFFF7ED);

  // Icon gradients
  static const Color _amber300 = Color(0xFFFCD34D);
  static const Color _amber400 = Color(0xFFFBBF24);
  static const Color _orange400 = Color(0xFFFB923C);
  static const Color _orange500 = Color(0xFFF97316);

  // Text colors
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  /// Sawtooth animation (0 -> 30px, then jumps back to 0) like the React interval.
  late final AnimationController _swipeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  /// Small chevron wiggle.
  late final AnimationController _chevronController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  /// Motion trail slide animation.
  late final AnimationController _trailController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat();

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
    _swipeController.dispose();
    _chevronController.dispose();
    _trailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_amber50, Colors.white, _orange50],
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
      child: Stack(
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
                    colors: [_amber300, _orange400],
                  ),
                ),
              ),
            ),
          ),

          // Motion trail (a thin gradient bar sliding horizontally)
          Positioned(
            left: 0,
            right: 0,
            child: SizedBox(
              height: 4,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _trailController,
                  builder: (context, child) {
                    // Slide from -100% to +300% like the React keyframes.
                    final t = _trailController.value; // 0..1
                    final dx = lerpDouble(-260, 780, t) ?? 0;
                    return Transform.translate(offset: Offset(dx, 0), child: child);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 80,
                      height: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.transparent, _amber300, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main icon circle, translated horizontally (swipeOffset)
          AnimatedBuilder(
            animation: _swipeController,
            builder: (context, child) {
              final dx = _swipeController.value * 30.0; // 0..30 then jump
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(56),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_amber400, _orange500],
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
                  AnimatedBuilder(
                    animation: _chevronController,
                    builder: (context, child) {
                      final wiggle = (_chevronController.value * 2 - 1) * 8.0;
                      return Transform.translate(offset: Offset(wiggle, 0), child: child);
                    },
                    child: const Icon(
                      Icons.chevron_right,
                      size: 84,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Decorative dot (ping) - top right
          Positioned(
            top: 14,
            right: 22,
            child: OnboardingPingDot(color: _amber300),
          ),

          // Decorative dot (pulse) - bottom left
          const Positioned(
            bottom: 6,
            left: 10,
            child: OnboardingPulseDot(color: Color(0xFFFDBA74)), // orange-300-ish
          ),
        ],
      ),
    );
  }
}
