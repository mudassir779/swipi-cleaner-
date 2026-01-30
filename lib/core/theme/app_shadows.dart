import 'package:flutter/material.dart';

/// Layered shadows with soft blur (Tailwind-ish `shadow-2xl` feel).
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> elevated({
    Color color = const Color(0xFF0F172A), // slate-900-ish
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.10),
        blurRadius: 32,
        offset: const Offset(0, 18),
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> subtle({
    Color color = const Color(0xFF0F172A),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 10),
      ),
    ];
  }
}

