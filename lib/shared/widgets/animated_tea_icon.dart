import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated tea/chai icon with steam animation - outline style (no colors)
class AnimatedTeaIcon extends StatefulWidget {
  final double size;
  final Color? strokeColor;
  final double strokeWidth;

  const AnimatedTeaIcon({
    super.key,
    this.size = 100,
    this.strokeColor,
    this.strokeWidth = 2,
  });

  @override
  State<AnimatedTeaIcon> createState() => _AnimatedTeaIconState();
}

class _AnimatedTeaIconState extends State<AnimatedTeaIcon>
    with TickerProviderStateMixin {
  late AnimationController _steamController;
  late AnimationController _cupController;
  late Animation<double> _steamAnimation;
  late Animation<double> _cupBounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Steam rising animation - continuous loop
    _steamController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _steamAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _steamController, curve: Curves.easeInOut),
    );
    
    // Subtle cup bounce animation
    _cupController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _cupBounceAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _cupController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _steamController.dispose();
    _cupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.strokeColor ?? 
        Theme.of(context).textTheme.bodyLarge?.color ?? 
        Colors.black;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_steamController, _cupController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _TeaCupPainter(
              strokeColor: color,
              strokeWidth: widget.strokeWidth,
              steamProgress: _steamAnimation.value,
              cupOffset: _cupBounceAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class _TeaCupPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final double steamProgress;
  final double cupOffset;

  _TeaCupPainter({
    required this.strokeColor,
    required this.strokeWidth,
    required this.steamProgress,
    required this.cupOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    
    // Apply subtle bounce to cup
    canvas.save();
    canvas.translate(0, cupOffset);
    
    // Draw tea cup body (outline)
    final cupPath = Path();
    final cupTop = h * 0.45;
    final cupBottom = h * 0.85;
    final cupLeft = w * 0.2;
    final cupRight = w * 0.7;
    
    // Cup body - slightly curved sides
    cupPath.moveTo(cupLeft, cupTop);
    cupPath.quadraticBezierTo(
      cupLeft - w * 0.02, 
      (cupTop + cupBottom) / 2, 
      cupLeft + w * 0.05, 
      cupBottom
    );
    cupPath.lineTo(cupRight - w * 0.05, cupBottom);
    cupPath.quadraticBezierTo(
      cupRight + w * 0.02, 
      (cupTop + cupBottom) / 2, 
      cupRight, 
      cupTop
    );
    
    canvas.drawPath(cupPath, paint);
    
    // Draw cup rim (top line)
    canvas.drawLine(
      Offset(cupLeft - w * 0.02, cupTop),
      Offset(cupRight + w * 0.02, cupTop),
      paint,
    );
    
    // Draw cup base (saucer line)
    final saucerY = cupBottom + h * 0.03;
    canvas.drawLine(
      Offset(cupLeft - w * 0.05, saucerY),
      Offset(cupRight + w * 0.05, saucerY),
      paint,
    );
    
    // Draw cup handle
    final handlePath = Path();
    final handleStartY = cupTop + h * 0.1;
    final handleEndY = cupBottom - h * 0.15;
    
    handlePath.moveTo(cupRight, handleStartY);
    handlePath.quadraticBezierTo(
      cupRight + w * 0.2,
      handleStartY,
      cupRight + w * 0.2,
      (handleStartY + handleEndY) / 2,
    );
    handlePath.quadraticBezierTo(
      cupRight + w * 0.2,
      handleEndY,
      cupRight,
      handleEndY,
    );
    
    canvas.drawPath(handlePath, paint);
    
    // Draw tea bag string and tag
    final teaBagStringStart = Offset(w * 0.55, cupTop);
    final teaBagStringEnd = Offset(w * 0.75, cupTop - h * 0.08);
    canvas.drawLine(teaBagStringStart, teaBagStringEnd, paint);
    
    // Tea bag tag (small rectangle)
    final tagRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.78, cupTop - h * 0.12),
        width: w * 0.1,
        height: h * 0.08,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(tagRect, paint);
    
    canvas.restore();
    
    // Draw animated steam (3 wavy lines)
    _drawSteam(canvas, size, paint);
  }

  void _drawSteam(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    
    // Steam paint with animated opacity
    final steamPaint = Paint()
      ..color = strokeColor.withOpacity(0.3 + (1 - steamProgress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round;
    
    final steamBaseY = h * 0.42 + cupOffset;
    final steamHeight = h * 0.35;
    
    // Three steam lines at different positions
    for (int i = 0; i < 3; i++) {
      final xOffset = w * 0.35 + (i * w * 0.1);
      final phaseOffset = i * 0.33;
      final progress = (steamProgress + phaseOffset) % 1.0;
      
      final steamPath = Path();
      final startY = steamBaseY - (progress * steamHeight * 0.3);
      
      steamPath.moveTo(xOffset, startY);
      
      // Wavy steam pattern
      for (int j = 0; j < 3; j++) {
        final segmentHeight = steamHeight / 4;
        final waveAmplitude = w * 0.03;
        final direction = (j % 2 == 0) ? 1 : -1;
        
        steamPath.quadraticBezierTo(
          xOffset + (waveAmplitude * direction * math.sin(progress * math.pi * 2 + j)),
          startY - (j + 0.5) * segmentHeight - (progress * steamHeight * 0.2),
          xOffset,
          startY - (j + 1) * segmentHeight - (progress * steamHeight * 0.2),
        );
      }
      
      // Fade out steam as it rises
      final fadedPaint = Paint()
        ..color = strokeColor.withOpacity((0.5 - progress * 0.4).clamp(0.1, 0.6))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.8 * (1 - progress * 0.3)
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(steamPath, fadedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TeaCupPainter oldDelegate) {
    return oldDelegate.steamProgress != steamProgress ||
        oldDelegate.cupOffset != cupOffset ||
        oldDelegate.strokeColor != strokeColor;
  }
}
