import React, { useState } from 'react';
import { View, Text, Pressable, Modal } from 'react-native';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { Ionicons } from '@expo/vector-icons';
import { format, startOfToday, startOfWeek, startOfMonth, startOfYear, subDays } from 'date-fns';
import DateTimePicker from '@react-native-community/datetimepicker';

export type DateFilterPreset = 'all' | 'today' | 'thisWeek' | 'thisMonth' | 'thisYear' | 'custom';

export interface DateFilter {
  preset: DateFilterPreset;
  startDate?: Date;
  endDate?: Date;
}

interface DateRangeFilterProps {
  filter: DateFilter;
  onFilterChange: (filter: DateFilter) => void;
}

export function DateRangeFilter({ filter, onFilterChange }: DateRangeFilterProps) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [showModal, setShowModal] = useState(false);
  const [showStartPicker, setShowStartPicker] = useState(false);
  const [showEndPicker, setShowEndPicker] = useState(false);
  const [tempStartDate, setTempStartDate] = useState(filter.startDate || new Date());
  const [tempEndDate, setTempEndDate] = useState(filter.endDate || new Date());

  const presets: { label: string; value: DateFilterPreset }[] = [
    { label: 'All Time', value: 'all' },
    { label: 'Today', value: 'today' },
    { label: 'This Week', value: 'thisWeek' },
    { label: 'This Month', value: 'thisMonth' },
    { label: 'This Year', value: 'thisYear' },
    { label: 'Custom', value: 'custom' },
  ];

  const handlePresetSelect = (preset: DateFilterPreset) => {
    let startDate: Date | undefined;
    let endDate: Date | undefined;

    const now = new Date();

    switch (preset) {
      case 'all':
        startDate = undefined;
        endDate = undefined;
        break;
      case 'today':
        startDate = startOfToday();
        endDate = now;
        break;
      case 'thisWeek':
        startDate = startOfWeek(now, { weekStartsOn: 1 });
        endDate = now;
        break;
      case 'thisMonth':
        startDate = startOfMonth(now);
        endDate = now;
        break;
      case 'thisYear':
        startDate = startOfYear(now);
        endDate = now;
        break;
      case 'custom':
        setShowModal(true);
        return;
    }

    onFilterChange({ preset, startDate, endDate });
    setShowModal(false);
  };

  const handleCustomDateApply = () => {
    onFilterChange({
      preset: 'custom',
      startDate: tempStartDate,
      endDate: tempEndDate,
    });
    setShowModal(false);
  };

  const getFilterLabel = () => {
    if (filter.preset === 'all') return 'All Time';
    if (filter.preset === 'custom') {
      if (filter.startDate && filter.endDate) {
        return `${format(filter.startDate, 'MMM d')} - ${format(filter.endDate, 'MMM d')}`;
      }
      return 'Custom';
    }
    return presets.find((p) => p.value === filter.preset)?.label || 'All Time';
  };

  return (
    <>
      <Pressable
        onPress={() => setShowModal(true)}
        className={cn(
          'px-3 py-2 rounded-full flex-row items-center',
          filter.preset !== 'all'
            ? 'bg-blue-500'
            : isDark
            ? 'bg-white/10'
            : 'bg-black/5'
        )}
      >
        <Ionicons
          name="calendar"
          size={16}
          color={
            filter.preset !== 'all'
              ? '#fff'
              : isDark
              ? '#94a3b8'
              : '#64748b'
          }
        />
        <Text
          className={cn(
            'text-sm font-medium ml-1.5',
            filter.preset !== 'all'
              ? 'text-white'
              : isDark
              ? 'text-slate-300'
              : 'text-slate-600'
          )}
        >
          {getFilterLabel()}
        </Text>
      </Pressable>

      <Modal
        visible={showModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowModal(false)}
      >
        <View
          className="flex-1 justify-end"
          style={{ backgroundColor: 'rgba(0, 0, 0, 0.5)' }}
        >
          <View
            className={cn('rounded-t-3xl', isDark ? 'bg-slate-900' : 'bg-white')}
            style={{ paddingBottom: 40 }}
          >
            {/* Header */}
            <View className="flex-row items-center justify-between px-4 py-4 border-b border-white/10">
              <Text
                className={cn(
                  'text-lg font-semibold',
                  isDark ? 'text-white' : 'text-slate-900'
                )}
              >
                Filter by Date
              </Text>
              <Pressable
                onPress={() => setShowModal(false)}
                className={cn(
                  'w-8 h-8 rounded-full items-center justify-center',
                  isDark ? 'bg-white/10' : 'bg-black/5'
                )}
              >
                <Ionicons name="close" size={20} color={isDark ? '#fff' : '#1e293b'} />
              </Pressable>
            </View>

            {/* Presets */}
            <View className="px-4 py-4">
              <Text
                className={cn(
                  'text-sm font-medium mb-3',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                Quick Filters
              </Text>
              {presets.map((preset) => (
                <Pressable
                  key={preset.value}
                  onPress={() => handlePresetSelect(preset.value)}
                  className={cn(
                    'py-3 px-4 rounded-xl mb-2',
                    filter.preset === preset.value
                      ? 'bg-blue-500'
                      : isDark
                      ? 'bg-white/5'
                      : 'bg-black/5'
                  )}
                >
                  <Text
                    className={cn(
                      'text-base',
                      filter.preset === preset.value
                        ? 'text-white font-semibold'
                        : isDark
                        ? 'text-white'
                        : 'text-slate-900'
                    )}
                  >
                    {preset.label}
                  </Text>
                </Pressable>
              ))}
            </View>

            {/* Custom Date Range */}
            {filter.preset === 'custom' && (
              <View className="px-4 py-4 border-t border-white/10">
                <Text
                  className={cn(
                    'text-sm font-medium mb-3',
                    isDark ? 'text-slate-400' : 'text-slate-500'
                  )}
                >
                  Custom Range
                </Text>

                <View className="space-y-3">
                  <Pressable
                    onPress={() => setShowStartPicker(true)}
                    className={cn(
                      'py-3 px-4 rounded-xl',
                      isDark ? 'bg-white/5' : 'bg-black/5'
                    )}
                  >
                    <Text
                      className={cn(
                        'text-xs mb-1',
                        isDark ? 'text-slate-400' : 'text-slate-500'
                      )}
                    >
                      Start Date
                    </Text>
                    <Text
                      className={cn('text-base', isDark ? 'text-white' : 'text-slate-900')}
                    >
                      {format(tempStartDate, 'MMMM d, yyyy')}
                    </Text>
                  </Pressable>

                  <Pressable
                    onPress={() => setShowEndPicker(true)}
                    className={cn(
                      'py-3 px-4 rounded-xl',
                      isDark ? 'bg-white/5' : 'bg-black/5'
                    )}
                  >
                    <Text
                      className={cn(
                        'text-xs mb-1',
                        isDark ? 'text-slate-400' : 'text-slate-500'
                      )}
                    >
                      End Date
                    </Text>
                    <Text
                      className={cn('text-base', isDark ? 'text-white' : 'text-slate-900')}
                    >
                      {format(tempEndDate, 'MMMM d, yyyy')}
                    </Text>
                  </Pressable>

                  <Pressable
                    onPress={handleCustomDateApply}
                    className="py-3 px-4 rounded-xl bg-blue-500 items-center"
                  >
                    <Text className="text-white font-semibold">Apply Filter</Text>
                  </Pressable>
                </View>
              </View>
            )}
          </View>
        </View>
      </Modal>

      {/* Date Pickers */}
      {showStartPicker && (
        <DateTimePicker
          value={tempStartDate}
          mode="date"
          display="default"
          onChange={(event, date) => {
            setShowStartPicker(false);
            if (date) {
              setTempStartDate(date);
            }
          }}
        />
      )}

      {showEndPicker && (
        <DateTimePicker
          value={tempEndDate}
          mode="date"
          display="default"
          onChange={(event, date) => {
            setShowEndPicker(false);
            if (date) {
              setTempEndDate(date);
            }
          }}
        />
      )}
    </>
  );
}
