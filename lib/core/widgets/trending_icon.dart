import 'package:flutter/material.dart';

class TrendingIcon extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const TrendingIcon({
    Key? key,
    this.size = 200,
    this.backgroundColor = const Color(0xFF4A9FE8),
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6EC5F0),
            const Color(0xFF3D6FCC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: size * 0.05,
            offset: Offset(0, size * 0.02),
          ),
        ],
      ),
      child: CustomPaint(
        painter: TrendingIconPainter(iconColor: iconColor),
      ),
    );
  }
}

class TrendingIconPainter extends CustomPainter {
  final Color iconColor;

  TrendingIconPainter({required this.iconColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    // Draw three upward trending arrows
    _drawArrow(canvas, size, paint, fillPaint, 0.25, 0.35); // Left arrow
    _drawArrow(canvas, size, paint, fillPaint, 0.5, 0.25);  // Middle arrow (taller)
    _drawArrow(canvas, size, paint, fillPaint, 0.75, 0.3);  // Right arrow

    // Draw two hands at the bottom with dotted line
    _drawHand(canvas, size, fillPaint, 0.3, 0.75);  // Left hand
    _drawHand(canvas, size, fillPaint, 0.7, 0.75);  // Right hand

    // Draw dotted connection line between hands
    _drawDottedLine(canvas, size, paint);
  }

  void _drawArrow(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint, 
                  double xRatio, double heightRatio) {
    final startX = size.width * xRatio;
    final startY = size.height * 0.65;
    final endY = size.height * heightRatio;
    
    // Draw curved arrow line
    final path = Path();
    path.moveTo(startX - size.width * 0.05, startY);
    
    final controlPoint1 = Offset(startX - size.width * 0.03, startY - size.height * 0.1);
    final controlPoint2 = Offset(startX - size.width * 0.01, endY + size.height * 0.1);
    final endPoint = Offset(startX, endY);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      endPoint.dx, endPoint.dy,
    );
    
    canvas.drawPath(path, strokePaint);
    
    // Draw arrowhead
    final arrowPath = Path();
    arrowPath.moveTo(startX, endY);
    arrowPath.lineTo(startX - size.width * 0.035, endY + size.height * 0.06);
    arrowPath.lineTo(startX + size.width * 0.035, endY + size.height * 0.06);
    arrowPath.close();
    
    canvas.drawPath(arrowPath, fillPaint);
  }

  void _drawHand(Canvas canvas, Size size, Paint paint, double xRatio, double yRatio) {
    final centerX = size.width * xRatio;
    final centerY = size.height * yRatio;
    
    // Draw pointing finger
    final fingerPath = Path();
    fingerPath.moveTo(centerX, centerY - size.height * 0.03);
    fingerPath.lineTo(centerX - size.width * 0.01, centerY + size.height * 0.02);
    fingerPath.lineTo(centerX + size.width * 0.01, centerY + size.height * 0.02);
    fingerPath.close();
    
    canvas.drawPath(fingerPath, paint);
    
    // Draw hand base
    final handPath = Path();
    handPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY + size.height * 0.035),
        width: size.width * 0.045,
        height: size.height * 0.035,
      ),
      Radius.circular(size.width * 0.015),
    ));
    
    canvas.drawPath(handPath, paint);
    
    // Draw tap circle indicator
    final circlePaint = Paint()
      ..color = paint.color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015;
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      size.width * 0.04,
      circlePaint,
    );
    
    // Draw inner circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      size.width * 0.02,
      circlePaint,
    );
  }

  void _drawDottedLine(Canvas canvas, Size size, Paint paint) {
    final dottedPaint = Paint()
      ..color = paint.color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.01;
    
    final startX = size.width * 0.35;
    final endX = size.width * 0.65;
    final y = size.height * 0.75;
    
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0;
    
    while (distance < (endX - startX)) {
      canvas.drawLine(
        Offset(startX + distance, y),
        Offset(startX + distance + dashWidth, y),
        dottedPaint,
      );
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(TrendingIconPainter oldDelegate) => false;
}
