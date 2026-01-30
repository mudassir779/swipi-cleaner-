import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DuplicateScanHero extends StatefulWidget {
  final String caption;

  const DuplicateScanHero({
    super.key,
    required this.caption,
  });

  @override
  State<DuplicateScanHero> createState() => _DuplicateScanHeroState();
}

class _DuplicateScanHeroState extends State<DuplicateScanHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent1 = Color(0xFF14B8A6); // teal
    const accent2 = Color(0xFF06B6D4); // cyan

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final floatY = math.sin(t * math.pi * 2) * 6;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent1.withValues(alpha: 0.18),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: accent2.withValues(alpha: 0.14),
                          blurRadius: 80,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  // Progress ring
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _RingPainter(
                      progress: t,
                      accent1: accent1,
                      accent2: accent2,
                    ),
                  ),
                  // Floating icon
                  Transform.translate(
                    offset: Offset(0, floatY),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accent1, accent2],
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.caption,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color accent1;
  final Color accent2;

  _RingPainter({
    required this.progress,
    required this.accent1,
    required this.accent2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = AppColors.divider.withValues(alpha: 0.7);

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
        colors: [accent1, accent2, accent1],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(rect);

    // Partial arc gives a “scan sweep” feel
    const arcSweep = math.pi * 1.2;
    canvas.drawArc(
      rect,
      -math.pi / 2 + (progress * math.pi * 2),
      arcSweep,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

