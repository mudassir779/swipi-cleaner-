import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design-system typography helpers aligned with the provided spec.
class AppTypography {
  const AppTypography._();

  /// Headings: ~`text-4xl font-bold tracking-tight`
  static TextStyle heading({Color color = AppColors.textPrimary}) {
    return const TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.15,
    ).copyWith(color: color);
  }

  /// Body: ~`text-lg text-gray-500 leading-relaxed`
  static TextStyle body({Color color = AppColors.textSecondary}) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ).copyWith(color: color);
  }

  /// Buttons: ~`text-lg font-semibold`
  static TextStyle button({Color color = Colors.white}) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ).copyWith(color: color);
  }

  static TextStyle label({Color color = AppColors.textSecondary}) {
    return const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.2,
    ).copyWith(color: color);
  }
}

