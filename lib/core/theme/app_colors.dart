import 'package:flutter/material.dart';

/// Design system color palette
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF87CEEB); // SkyBlue
  static const Color primaryLight = Color(0xFFB0E2F5); // Lighter SkyBlue
  static const Color secondary = Color(0xFFFF7B7B); // Coral/pink

  // Background colors
  static const Color background = Color(0xFFF8F9FA); // Off-white
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBackground = Color(0xFFFFF5F5); // Pink-tinted
  static const Color snow = Color(0xFFFFFAFA); // Snow white

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Near black
  static const Color textSecondary = Color(0xFF6B7280); // Gray

  // Semantic colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color green = Color(0xFF10B981); // Alias
  static const Color error = Color(0xFFFF3B30); // iOS red
  static const Color red = Color(0xFFFF3B30); // Alias
  static const Color warning = Color(0xFFF59E0B); // Amber

  // UI element colors
  static const Color slateIcon = Color(0xFF71C4D9); // Light blue/cyan for icons
  static const Color divider = Color(0xFFE5E7EB); // Light gray
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Feature-specific colors
  static const Color countRed = Color(0xFFFF6B6B); // For deletion counts
  static const Color countBlue = Color(0xFF3B82F6); // For info counts
  static const Color countCyan = Color(0xFF06B6D4); // For special counts

  // Legacy aliases (for backward compatibility)
  static const Color gray = textSecondary;
  static const Color sectionHeader = textSecondary;
  static const Color surfaceLight = surface;
  static const Color teal = primary;
  static const Color pink = secondary;
  static const Color seaShell = cardBackground;

  // Gradients
  static const List<Color> gradientPrimary = [
    Color(0xFF87CEEB),
    Color(0xFF5FB6E0),
  ];
  static const List<Color> gradientCoral = [
    Color(0xFFFF7B7B),
    Color(0xFFFF6B6B),
  ];
  static const List<Color> gradientGreen = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  static const List<Color> gradientRed = [
    Color(0xFFFF416C),
    Color(0xFFFF4B2B),
  ];
  static const List<Color> gradientBlue = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];
  static const List<Color> gradientTeal = [
    Color(0xFF11998E),
    Color(0xFF38EF7D),
  ];
  static const List<Color> gradientPurple = gradientPrimary;
}
