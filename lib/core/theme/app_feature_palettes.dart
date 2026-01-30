import 'package:flutter/material.dart';

/// Feature-based color palette used for gradients and accents.
///
/// Maps closely to the design spec:
/// - subtle background gradients: from-[color]-50 via-white to-[color]-50
/// - each screen gets a cohesive start/end palette
@immutable
class AppFeaturePalette {
  final Color start;
  final Color end;
  final Color accent;

  const AppFeaturePalette({
    required this.start,
    required this.end,
    required this.accent,
  });

  /// Subtle background gradient: softened start/end with white in the middle.
  LinearGradient backgroundGradient({
    Alignment begin = Alignment.topLeft,
    Alignment endAlignment = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: endAlignment,
      colors: [
        _soft(start),
        Colors.white,
        _soft(end),
      ],
    );
  }

  /// Stronger accent gradient for buttons/badges.
  LinearGradient accentGradient({
    Alignment begin = Alignment.topLeft,
    Alignment endAlignment = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: endAlignment,
      colors: [start, end],
    );
  }

  static Color _soft(Color c) => Color.lerp(c, Colors.white, 0.86)!;
}

/// Central registry of feature palettes.
class AppFeaturePalettes {
  const AppFeaturePalettes._();

  /// Photo Gallery: Rose/Coral (#FF6B6B to #FF8E53)
  static const AppFeaturePalette gallery = AppFeaturePalette(
    start: Color(0xFFFF6B6B),
    end: Color(0xFFFF8E53),
    accent: Color(0xFFFF6B6B),
  );

  /// Swipe Actions: Amber/Orange (#FFA726 to #FF7043)
  static const AppFeaturePalette swipe = AppFeaturePalette(
    start: Color(0xFFFFA726),
    end: Color(0xFFFF7043),
    accent: Color(0xFFFFA726),
  );

  /// Collections: Blue/Indigo (#42A5F5 to #5E35B1)
  static const AppFeaturePalette collections = AppFeaturePalette(
    start: Color(0xFF42A5F5),
    end: Color(0xFF5E35B1),
    accent: Color(0xFF42A5F5),
  );

  /// Security: Emerald/Green (#26A69A to #66BB6A)
  static const AppFeaturePalette security = AppFeaturePalette(
    start: Color(0xFF26A69A),
    end: Color(0xFF66BB6A),
    accent: Color(0xFF26A69A),
  );

  /// Storage: Purple/Violet (#AB47BC to #7E57C2)
  static const AppFeaturePalette storage = AppFeaturePalette(
    start: Color(0xFFAB47BC),
    end: Color(0xFF7E57C2),
    accent: Color(0xFFAB47BC),
  );

  /// Duplicates: Teal/Cyan (#26C6DA to #00ACC1)
  static const AppFeaturePalette duplicates = AppFeaturePalette(
    start: Color(0xFF26C6DA),
    end: Color(0xFF00ACC1),
    accent: Color(0xFF00ACC1),
  );
}

