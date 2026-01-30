import 'dart:math';
import 'package:flutter/material.dart';

/// Simple confetti animation overlay for celebrations
class ConfettiOverlay extends StatefulWidget {
  final bool show;
  final VoidCallback? onComplete;
  final Duration duration;
  
  const ConfettiOverlay({
    super.key,
    this.show = true,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;
  final Random _random = Random();

  static const List<Color> _colors = [
    Color(0xFFFF6B6B), // Coral
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFF38181), // Pink
    Color(0xFF7B68EE), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _generatePieces();
    
    if (widget.show) {
      _controller.forward();
    }
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  void _generatePieces() {
    _pieces = List.generate(50, (index) {
      return _ConfettiPiece(
        x: _random.nextDouble(),
        delay: _random.nextDouble() * 0.5,
        speed: 0.5 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: -180 + _random.nextDouble() * 360,
        size: 8 + _random.nextDouble() * 8,
        color: _colors[_random.nextInt(_colors.length)],
        shape: _random.nextBool() ? _ConfettiShape.rect : _ConfettiShape.circle,
      );
    });
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _generatePieces();
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

enum _ConfettiShape { rect, circle }

class _ConfettiPiece {
  final double x;
  final double delay;
  final double speed;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final _ConfettiShape shape;

  _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({
    required this.pieces,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final adjustedProgress = (progress - piece.delay).clamp(0.0, 1.0) * piece.speed;
      
      if (adjustedProgress <= 0) continue;
      
      final x = piece.x * size.width;
      final y = adjustedProgress * size.height * 1.2;
      final rotation = (piece.rotation + piece.rotationSpeed * adjustedProgress) * pi / 180;
      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = piece.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      if (piece.shape == _ConfettiShape.rect) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Helper widget to show confetti
class ConfettiController {
  final ValueNotifier<bool> _showNotifier = ValueNotifier(false);
  
  ValueNotifier<bool> get notifier => _showNotifier;
  
  void play() {
    _showNotifier.value = true;
  }
  
  void stop() {
    _showNotifier.value = false;
  }
  
  void dispose() {
    _showNotifier.dispose();
  }
}
