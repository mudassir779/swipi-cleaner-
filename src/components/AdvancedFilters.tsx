import React, { useState } from 'react';
import { View, Text, Pressable, Modal } from 'react-native';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';

export type PhotoTypeFilter = 'all' | 'screenshots' | 'selfies' | 'live' | 'burst';
export type SizeFilter = 'all' | 'large' | 'small' | 'medium';

interface AdvancedFiltersProps {
  photoTypeFilter: PhotoTypeFilter;
  sizeFilter: SizeFilter;
  onPhotoTypeChange: (filter: PhotoTypeFilter) => void;
  onSizeChange: (filter: SizeFilter) => void;
}

export function AdvancedFilters({
  photoTypeFilter,
  sizeFilter,
  onPhotoTypeChange,
  onSizeChange,
}: AdvancedFiltersProps) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [showModal, setShowModal] = useState(false);

  const photoTypeOptions: { label: string; value: PhotoTypeFilter }[] = [
    { label: 'All Types', value: 'all' },
    { label: 'Screenshots', value: 'screenshots' },
    { label: 'Selfies', value: 'selfies' },
    { label: 'Live Photos', value: 'live' },
    { label: 'Burst Photos', value: 'burst' },
  ];

  const sizeOptions: { label: string; value: SizeFilter }[] = [
    { label: 'All Sizes', value: 'all' },
    { label: 'Large (>10MB)', value: 'large' },
    { label: 'Medium (1-10MB)', value: 'medium' },
    { label: 'Small (<1MB)', value: 'small' },
  ];

  const hasActiveFilters = photoTypeFilter !== 'all' || sizeFilter !== 'all';

  return (
    <>
      <Pressable
        onPress={() => {
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
          setShowModal(true);
        }}
        className={cn(
          'px-3 py-2 rounded-full flex-row items-center',
          hasActiveFilters
            ? 'bg-blue-500'
            : isDark
            ? 'bg-white/10'
            : 'bg-black/5'
        )}
      >
        <Ionicons
          name="filter"
          size={16}
          color={hasActiveFilters ? '#fff' : isDark ? '#94a3b8' : '#64748b'}
        />
        {hasActiveFilters && (
          <View className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-red-500" />
        )}
      </Pressable>

      <Modal
        visible={showModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowModal(false)}
      >
        <View className="flex-1 bg-black/50">
          <Pressable
            className="flex-1"
            onPress={() => setShowModal(false)}
          />
          <View
            className={cn(
              'rounded-t-3xl pb-8',
              isDark ? 'bg-slate-900' : 'bg-white'
            )}
            style={{ paddingTop: 20 }}
          >
            <View className="flex-row items-center justify-between px-6 mb-6">
              <Text
                className={cn(
                  'text-xl font-bold',
                  isDark ? 'text-white' : 'text-slate-900'
                )}
              >
                Filters
              </Text>
              <Pressable
                onPress={() => setShowModal(false)}
                className={cn(
                  'w-8 h-8 rounded-full items-center justify-center',
                  isDark ? 'bg-white/10' : 'bg-black/5'
                )}
              >
                <Ionicons
                  name="close"
                  size={20}
                  color={isDark ? '#fff' : '#1e293b'}
                />
              </Pressable>
            </View>

            {/* Photo Type Filter */}
            <View className="px-6 mb-6">
              <Text
                className={cn(
                  'text-sm font-semibold mb-3',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                PHOTO TYPE
              </Text>
              <View className="flex-row flex-wrap gap-2">
                {photoTypeOptions.map((option) => (
                  <Pressable
                    key={option.value}
                    onPress={() => {
                      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      onPhotoTypeChange(option.value);
                    }}
                    className={cn(
                      'px-4 py-2.5 rounded-full',
                      photoTypeFilter === option.value
                        ? 'bg-blue-500'
                        : isDark
                        ? 'bg-white/10'
                        : 'bg-black/5'
                    )}
                  >
                    <Text
                      className={cn(
                        'text-sm font-medium',
                        photoTypeFilter === option.value
                          ? 'text-white'
                          : isDark
                          ? 'text-slate-300'
                          : 'text-slate-600'
                      )}
                    >
                      {option.label}
                    </Text>
                  </Pressable>
                ))}
              </View>
            </View>

            {/* Size Filter */}
            <View className="px-6 mb-6">
              <Text
                className={cn(
                  'text-sm font-semibold mb-3',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                FILE SIZE
              </Text>
              <View className="flex-row flex-wrap gap-2">
                {sizeOptions.map((option) => (
                  <Pressable
                    key={option.value}
                    onPress={() => {
                      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      onSizeChange(option.value);
                    }}
                    className={cn(
                      'px-4 py-2.5 rounded-full',
                      sizeFilter === option.value
                        ? 'bg-blue-500'
                        : isDark
                        ? 'bg-white/10'
                        : 'bg-black/5'
                    )}
                  >
                    <Text
                      className={cn(
                        'text-sm font-medium',
                        sizeFilter === option.value
                          ? 'text-white'
                          : isDark
                          ? 'text-slate-300'
                          : 'text-slate-600'
                      )}
                    >
                      {option.label}
                    </Text>
                  </Pressable>
                ))}
              </View>
            </View>

            {/* Clear Filters */}
            {hasActiveFilters && (
              <View className="px-6">
                <Pressable
                  onPress={() => {
                    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                    onPhotoTypeChange('all');
                    onSizeChange('all');
                  }}
                  className={cn(
                    'py-3 rounded-xl items-center',
                    isDark ? 'bg-white/10' : 'bg-black/5'
                  )}
                >
                  <Text
                    className={cn(
                      'text-base font-medium',
                      isDark ? 'text-white' : 'text-slate-900'
                    )}
                  >
                    Clear All Filters
                  </Text>
                </Pressable>
              </View>
            )}
          </View>
        </View>
      </Modal>
    </>
  );
}
