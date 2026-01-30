import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';

import 'onboarding_effects.dart';

/// Fourth onboarding hero that matches the v0 (React/Tailwind) Safe & Secure design:
/// emerald/green gradient background, glowing ring, shield rings, particles, and lock pulse.
class SafeSecureOnboardingHero extends StatefulWidget {
  final String title;
  final String description;

  const SafeSecureOnboardingHero({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<SafeSecureOnboardingHero> createState() => _SafeSecureOnboardingHeroState();
}

class _SafeSecureOnboardingHeroState extends State<SafeSecureOnboardingHero>
    with TickerProviderStateMixin {
  // Background (Tailwind-ish)
  static const Color _emerald50 = Color(0xFFECFDF5);
  static const Color _green50 = Color(0xFFF0FDF4);

  // Glow + icon gradients
  static const Color _emerald300 = Color(0xFF6EE7B7);
  static const Color _green400 = Color(0xFF4ADE80);
  static const Color _emerald500 = Color(0xFF10B981);
  static const Color _green600 = Color(0xFF16A34A);

  // Text colors
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat(reverse: true);

  // Pulse every 2s (quick 500ms-ish bump like the React interval).
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  // Slow ring ping (3s)
  late final AnimationController _ringController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat();

  // Particle drift (4s)
  late final AnimationController _particleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
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
    _floatController.dispose();
    _pulseController.dispose();
    _ringController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_emerald50, Colors.white, _green50],
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
                    const SizedBox(height: 24),
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
      height: 240,
      width: 240,
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
                    colors: [_emerald300, _green400],
                  ),
                ),
              ),
            ),
          ),

          // Security rings (ping + static)
          AnimatedBuilder(
            animation: _ringController,
            builder: (context, child) {
              final t = _ringController.value; // 0..1
              final scale = lerpDouble(1.0, 1.5, t) ?? 1.0;
              final opacity = lerpDouble(0.8, 0.0, t) ?? 0.0;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _emerald300.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _emerald300.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),

          // Main icon circle (float + pulse)
          AnimatedBuilder(
            animation: Listenable.merge([_floatController, _pulseController]),
            builder: (context, child) {
              final floatY = lerpDouble(0, -10, _floatController.value) ?? 0;

              // Pulse: quick bump at the beginning of each 2s cycle
              final p = _pulseController.value;
              final bump = p < 0.25 ? math.sin(p / 0.25 * math.pi) : 0.0;
              final scale = 1.0 + (bump * 0.10);

              return Transform.translate(
                offset: Offset(0, floatY),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(56),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_emerald500, _green600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.lock_outline,
                    size: 84,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Security particles (slow drifting dots)
          Positioned(
            top: 56,
            right: 18,
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                final t = _particleController.value;
                final dx1 = lerpDouble(0, -10, t) ?? 0;
                final dy1 = lerpDouble(0, -15, t) ?? 0;
                return Transform.translate(offset: Offset(dx1, dy1), child: child);
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _emerald500.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 18,
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                final t = _particleController.value;
                final dx2 = lerpDouble(0, 10, t) ?? 0;
                final dy2 = lerpDouble(0, 15, t) ?? 0;
                return Transform.translate(offset: Offset(dx2, dy2), child: child);
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _green400.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 78,
            left: 72,
            child: OnboardingPulseDot(color: _emerald300, size: 6),
          ),

          // Decorative dots
          const Positioned(
            top: 14,
            right: 22,
            child: OnboardingPingDot(color: _emerald300),
          ),
          const Positioned(
            bottom: 10,
            left: 12,
            child: OnboardingPulseDot(color: Color(0xFF86EFAC)), // green-300-ish
          ),
        ],
      ),
    );
  }
}

