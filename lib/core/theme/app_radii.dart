import 'package:flutter/material.dart';

/// Consistent corner radii across the app.
class AppRadii {
  const AppRadii._();

  /// Equivalent to `rounded-2xl`.
  static const double r2xl = 24;

  /// General large rounding for cards/sheets.
  static const double xl = 20;

  /// Common default rounding for smaller components.
  static const double lg = 16;

  static const double md = 12;
  static const double sm = 8;

  /// Equivalent to `rounded-full`.
  static const double full = 999;

  static BorderRadius borderRadius(double radius) => BorderRadius.circular(radius);
}

