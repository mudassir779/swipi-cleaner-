import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_filter.dart';

/// Provider for photo filters
final filterProvider =
    StateNotifierProvider<FilterNotifier, PhotoFilter>((ref) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<PhotoFilter> {
  FilterNotifier() : super(PhotoFilter.defaultFilter);

  /// Set date filter preset
  void setDatePreset(DateFilterPreset preset) {
    DateTime? startDate;
    DateTime? endDate;

    final now = DateTime.now();

    switch (preset) {
      case DateFilterPreset.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateFilterPreset.thisWeek:
        final weekDay = now.weekday;
        startDate = now.subtract(Duration(days: weekDay - 1));
        endDate = now;
        break;
      case DateFilterPreset.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case DateFilterPreset.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
        break;
      case DateFilterPreset.custom:
      case DateFilterPreset.all:
        startDate = null;
        endDate = null;
        break;
    }

    state = state.copyWith(
      datePreset: preset,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Set custom date range
  void setCustomDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      datePreset: DateFilterPreset.custom,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Set photo type filter
  void setTypeFilter(PhotoTypeFilter filter) {
    state = state.copyWith(typeFilter: filter);
  }

  /// Set size filter
  void setSizeFilter(SizeFilter filter) {
    state = state.copyWith(sizeFilter: filter);
  }

  /// Set sort by
  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Set sort order
  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  /// Toggle sort order
  void toggleSortOrder() {
    final newOrder = state.sortOrder == SortOrder.asc
        ? SortOrder.desc
        : SortOrder.asc;
    state = state.copyWith(sortOrder: newOrder);
  }

  /// Set search query
  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Reset all filters
  void reset() {
    state = PhotoFilter.defaultFilter;
  }

  /// Check if filters are active
  bool get hasActiveFilters => state.hasActiveFilters;
}
