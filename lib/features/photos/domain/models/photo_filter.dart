/// Filter options for photos
class PhotoFilter {
  final DateFilterPreset datePreset;
  final DateTime? startDate;
  final DateTime? endDate;
  final PhotoTypeFilter typeFilter;
  final SizeFilter sizeFilter;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final String? searchQuery;

  const PhotoFilter({
    this.datePreset = DateFilterPreset.all,
    this.startDate,
    this.endDate,
    this.typeFilter = PhotoTypeFilter.all,
    this.sizeFilter = SizeFilter.all,
    this.sortBy = SortBy.date,
    this.sortOrder = SortOrder.desc,
    this.searchQuery,
  });

  PhotoFilter copyWith({
    DateFilterPreset? datePreset,
    DateTime? startDate,
    DateTime? endDate,
    PhotoTypeFilter? typeFilter,
    SizeFilter? sizeFilter,
    SortBy? sortBy,
    SortOrder? sortOrder,
    String? searchQuery,
  }) {
    return PhotoFilter(
      datePreset: datePreset ?? this.datePreset,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      typeFilter: typeFilter ?? this.typeFilter,
      sizeFilter: sizeFilter ?? this.sizeFilter,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return datePreset != DateFilterPreset.all ||
        typeFilter != PhotoTypeFilter.all ||
        sizeFilter != SizeFilter.all ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }

  /// Reset all filters to default
  static const PhotoFilter defaultFilter = PhotoFilter();
}

enum DateFilterPreset {
  all,
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

enum PhotoTypeFilter {
  all,
  screenshots,
  selfies,
  live,
  burst,
}

enum SizeFilter {
  all,
  large, // >10MB
  medium, // 5-10MB
  small, // <5MB
}

enum SortBy {
  date,
  size,
  name,
}

enum SortOrder {
  asc,
  desc,
}
