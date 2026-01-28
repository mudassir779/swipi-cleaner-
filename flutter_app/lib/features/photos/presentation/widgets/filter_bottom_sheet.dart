import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/photo_filter.dart';
import '../../domain/providers/filter_provider.dart';

/// Bottom sheet for photo filters
class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: AppTextStyles.title,
              ),
              TextButton(
                onPressed: () {
                  ref.read(filterProvider.notifier).reset();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date filter
          const Text(
            'DATE RANGE',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: DateFilterPreset.values.map((preset) {
              return ChoiceChip(
                label: Text(_getDatePresetLabel(preset)),
                selected: filter.datePreset == preset,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(filterProvider.notifier).setDatePreset(preset);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Size filter
          const Text(
            'FILE SIZE',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SizeFilter.values.map((size) {
              return ChoiceChip(
                label: Text(_getSizeFilterLabel(size)),
                selected: filter.sizeFilter == size,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(filterProvider.notifier).setSizeFilter(size);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Sort options
          const Text(
            'SORT BY',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButton<SortBy>(
                  value: filter.sortBy,
                  isExpanded: true,
                  items: SortBy.values.map((sort) {
                    return DropdownMenuItem(
                      value: sort,
                      child: Text(_getSortByLabel(sort)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(filterProvider.notifier).setSortBy(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  filter.sortOrder == SortOrder.asc
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
                onPressed: () {
                  ref.read(filterProvider.notifier).toggleSortOrder();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  String _getDatePresetLabel(DateFilterPreset preset) {
    switch (preset) {
      case DateFilterPreset.all:
        return 'All';
      case DateFilterPreset.today:
        return 'Today';
      case DateFilterPreset.thisWeek:
        return 'This Week';
      case DateFilterPreset.thisMonth:
        return 'This Month';
      case DateFilterPreset.thisYear:
        return 'This Year';
      case DateFilterPreset.custom:
        return 'Custom';
    }
  }

  String _getSizeFilterLabel(SizeFilter filter) {
    switch (filter) {
      case SizeFilter.all:
        return 'All';
      case SizeFilter.large:
        return 'Large (>10MB)';
      case SizeFilter.medium:
        return 'Medium (5-10MB)';
      case SizeFilter.small:
        return 'Small (<5MB)';
    }
  }

  String _getSortByLabel(SortBy sort) {
    switch (sort) {
      case SortBy.date:
        return 'Date';
      case SortBy.size:
        return 'Size';
      case SortBy.name:
        return 'Name';
    }
  }
}
