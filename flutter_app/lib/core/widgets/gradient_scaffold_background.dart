import 'package:flutter/material.dart';

class GradientScaffoldBackground extends StatelessWidget {
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final Widget child;

  const GradientScaffoldBackground({
    super.key,
    required this.colors,
    required this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

