import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadow styles for the design system
class AppShadows {
  // Card shadow - subtle depth
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Elevated card - more prominent
  static List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Primary button shadow
  static List<BoxShadow> buttonPrimary = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Floating button shadow (coral)
  static List<BoxShadow> buttonFloating = [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // Delete/danger button shadow
  static List<BoxShadow> buttonDanger = [
    BoxShadow(
      color: AppColors.red.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Success button shadow
  static List<BoxShadow> buttonSuccess = [
    BoxShadow(
      color: AppColors.green.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // No shadow
  static List<BoxShadow> none = [];
}
