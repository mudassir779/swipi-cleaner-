import 'package:flutter/material.dart';

class PrimaryGradientButton extends StatelessWidget {
  final List<Color> colors;
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final BorderRadius borderRadius;

  const PrimaryGradientButton({
    super.key,
    required this.colors,
    required this.onPressed,
    required this.child,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: borderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

