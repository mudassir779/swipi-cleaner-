import 'package:flutter/material.dart';
import 'photo.dart';
import '../../../../core/theme/app_colors.dart';

/// Group of photos from the same month
class MonthGroup {
  final String monthKey; // Format: "2025-12"
  final DateTime monthDate;
  final List<Photo> photos;

  const MonthGroup({
    required this.monthKey,
    required this.monthDate,
    required this.photos,
  });

  /// Number of photos in this month
  int get photoCount => photos.length;

  /// Formatted month display name (e.g., "DEC '25")
  String get displayName {
    const monthAbbr = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final month = monthAbbr[monthDate.month - 1];
    final year = monthDate.year.toString().substring(2); // Last 2 digits
    return "$month '$year";
  }

  /// Get month key from a DateTime
  static String getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Get background color for month band (alternating for visual separation)
  Color getBackgroundColor(int index) {
    return index.isEven ? AppColors.background : AppColors.cardBackground;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthGroup &&
          runtimeType == other.runtimeType &&
          monthKey == other.monthKey;

  @override
  int get hashCode => monthKey.hashCode;
}
