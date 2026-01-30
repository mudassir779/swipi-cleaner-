import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AnimatedDonutChart extends StatefulWidget {
  final double progress; // 0..1
  final List<Color> gradient;
  final String centerLabel;
  final String centerValue;

  const AnimatedDonutChart({
    super.key,
    required this.progress,
    required this.gradient,
    required this.centerLabel,
    required this.centerValue,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
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
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        final animatedProgress = (widget.progress * t).clamp(0.0, 1.0);
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(220, 220),
              painter: _DonutPainter(
                progress: animatedProgress,
                gradient: widget.gradient,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.centerValue,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.centerLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final List<Color> gradient;

  _DonutPainter({
    required this.progress,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = AppColors.divider.withValues(alpha: 0.9);

    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
        colors: gradient,
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, sweep);
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.gradient != gradient;
  }
}

