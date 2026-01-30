import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A simple "ping" dot (grows + fades) like Tailwind's `animate-ping`.
class OnboardingPingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const OnboardingPingDot({
    super.key,
    required this.color,
    this.size = 12,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<OnboardingPingDot> createState() => _OnboardingPingDotState();
}

class _OnboardingPingDotState extends State<OnboardingPingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

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
        final t = _controller.value; // 0..1
        final scale = lerpDouble(1.0, 2.2, t) ?? 1.0;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// A simple "pulse" dot (fades in/out) like Tailwind's `animate-pulse`.
class OnboardingPulseDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const OnboardingPulseDot({
    super.key,
    required this.color,
    this.size = 8,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<OnboardingPulseDot> createState() => _OnboardingPulseDotState();
}

class _OnboardingPulseDotState extends State<OnboardingPulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

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
        final t = _controller.value;
        final opacity = lerpDouble(0.45, 0.80, t) ?? 0.6;
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

