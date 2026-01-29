import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'month_photos_provider.dart';

/// Model for month information in the picker
class MonthInfo {
  final String monthKey; // YYYY-MM format
  final DateTime monthDate;
  final String displayName; // e.g., "JAN '26"
  final int photoCount;

  const MonthInfo({
    required this.monthKey,
    required this.monthDate,
    required this.displayName,
    required this.photoCount,
  });

  /// Get year for grouping
  int get year => monthDate.year;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthInfo &&
          runtimeType == other.runtimeType &&
          monthKey == other.monthKey;

  @override
  int get hashCode => monthKey.hashCode;
}

/// Provider for available months with photo counts
final availableMonthsProvider = FutureProvider<List<MonthInfo>>((ref) async {
  final monthGroups = await ref.watch(monthPhotosProvider.future);

  // Convert month groups to MonthInfo list
  final monthInfos = monthGroups.map((group) {
    final monthDate = group.monthDate;
    final displayName = DateFormat('MMM \'yy').format(monthDate).toUpperCase();

    return MonthInfo(
      monthKey: group.monthKey,
      monthDate: monthDate,
      displayName: displayName,
      photoCount: group.photoCount,
    );
  }).toList();

  // Already sorted by monthPhotosProvider (descending - newest first)
  return monthInfos;
});

/// Provider for currently selected month (null = no selection)
final selectedMonthProvider = StateProvider<String?>((ref) => null);
