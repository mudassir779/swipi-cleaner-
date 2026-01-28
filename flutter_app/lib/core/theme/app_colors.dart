import 'package:flutter/material.dart';

/// App color scheme matching the React Native design
class AppColors {
  // Base colors (Clean minimal design)
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBackground = Color(0xFFF9FAFB); // Soft Gray

  // Text colors
  static const Color textPrimary = Color(0xFF111827); // Primary Text
  static const Color textSecondary = Color(0xFF6B7280); // Secondary Text
  static const Color sectionHeader = Color(0xFF6B7280);

  // Border colors
  static const Color divider = Color(0xFFE5E7EB); // Divider Gray
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Accent colors
  static const Color primary = Color(0xFF3B82F6);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFEA580C);
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkDark = Color(0xFFDB2777);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF7C3AED);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueDark = Color(0xFF2563EB);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color yellowDark = Color(0xFFD97706);
  static const Color gray = Color(0xFF6B7280);
  static const Color grayDark = Color(0xFF4B5563);
  static const Color red = Color(0xFFEF4444);
  static const Color redDark = Color(0xFFDC2626);
  static const Color green = Color(0xFF10B981);
  static const Color greenDark = Color(0xFF059669);

  // Stats card background colors
  static const Color statsPhotos = Color(0xFF1E3A5F); // Blue tint
  static const Color statsVideos = Color(0xFF2D1F4E); // Purple tint
  static const Color statsToday = Color(0xFF1A3D2E); // Green tint
  static const Color statsToDelete = Color(0xFF3D1F1F); // Red tint

  // Gradients
  static const List<Color> gradientTeal = [teal, tealDark];
  static const List<Color> gradientOrange = [orange, orangeDark];
  static const List<Color> gradientPink = [pink, pinkDark];
  static const List<Color> gradientPurple = [purple, purpleDark];
  static const List<Color> gradientBlue = [blue, blueDark];
  static const List<Color> gradientYellow = [yellow, yellowDark];
  static const List<Color> gradientGray = [gray, grayDark];
  static const List<Color> gradientRed = [red, redDark];
  static const List<Color> gradientGreen = [green, greenDark];
}
