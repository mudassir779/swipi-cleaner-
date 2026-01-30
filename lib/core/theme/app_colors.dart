import 'package:flutter/material.dart';

/// Apple-style minimal color scheme
class AppColors {
  // Base colors (white/gray)
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color snow = Color(0xFFFFFAFA); // Snow
  static const Color seaShell = Color(0xFFFFF5EE); // SeaShell
  static const Color slateIcon = Color(0xFF7C8DB5); // Slate Blue for icons
  static const Color surface = Color(0xFFF9FAFB); // Light gray
  static const Color cardBackground = seaShell;

  // Text colors
  static const Color textPrimary = Color(0xFF111827); // Dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Muted gray

  // Border colors
  static const Color divider = Color(0xFFE5E7EB); // Light gray
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Accent colors (Coral for unique personality)
  static const Color primary = Color(0xFFFF6B6B); // Coral/Salmon
  static const Color green = Color(0xFF34C759); // iOS green
  static const Color red = Color(0xFFFF3B30); // iOS red
  static const Color error = Color(0xFFFF3B30); // iOS red

  // Legacy aliases (for gradual migration)
  static const Color gray = Color(0xFF6B7280); // Same as textSecondary
  static const Color sectionHeader = Color(0xFF6B7280); // Same as textSecondary
  static const Color surfaceLight = Color(0xFFF9FAFB); // Same as surface
  static const Color teal = Color(0xFFFF6B6B); // Now maps to primary coral
  static const Color pink = Color(0xFFFF6B6B); // Now maps to primary coral

  // Legacy gradients (now use minimal colors)
  static const List<Color> gradientRed = [red, red];
  static const List<Color> gradientBlue = [primary, primary];
  static const List<Color> gradientTeal = [primary, primary];
  static const List<Color> gradientPurple = [primary, primary];
  static const List<Color> gradientGreen = [green, green];
}
