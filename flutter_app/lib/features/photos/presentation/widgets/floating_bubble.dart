import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Floating bubble button showing count of photos marked for deletion
/// iOS/WhatsApp-style circular button that appears in top-right corner
class FloatingBubble extends StatefulWidget {
  final int count;
  final VoidCallback onTap;

  const FloatingBubble({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble> {
  bool _isVisible = false;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    // Trigger entrance animation
    Future.microtask(() {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  void didUpdateWidget(FloatingBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger pulse animation when count changes
    if (widget.count != _previousCount) {
      _previousCount = widget.count;
      // Pulse effect
      setState(() => _isVisible = false);
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() => _isVisible = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.red.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
