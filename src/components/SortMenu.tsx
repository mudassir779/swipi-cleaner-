import React, { useState } from 'react';
import { View, Text, Pressable, Modal } from 'react-native';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';

export type SortOption = 'date' | 'size' | 'name';
export type SortOrder = 'asc' | 'desc';

interface SortMenuProps {
  sortBy: SortOption;
  sortOrder: SortOrder;
  onSortChange: (sortBy: SortOption, sortOrder: SortOrder) => void;
}

export function SortMenu({ sortBy, sortOrder, onSortChange }: SortMenuProps) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [showModal, setShowModal] = useState(false);

  const sortOptions: { label: string; value: SortOption; icon: React.ReactNode }[] = [
    { label: 'Date', value: 'date', icon: <Ionicons name="calendar" size={18} color={isDark ? '#94a3b8' : '#64748b'} /> },
    { label: 'Size', value: 'size', icon: <Ionicons name="hardware-chip" size={18} color={isDark ? '#94a3b8' : '#64748b'} /> },
    { label: 'Name', value: 'name', icon: <Ionicons name="document-text" size={18} color={isDark ? '#94a3b8' : '#64748b'} /> },
  ];

  const handleSortOptionSelect = (option: SortOption) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    if (sortBy === option) {
      // Toggle order if same option
      onSortChange(option, sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      // Set new option with default desc order
      onSortChange(option, 'desc');
    }
    setShowModal(false);
  };

  const handleOrderToggle = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    onSortChange(sortBy, sortOrder === 'asc' ? 'desc' : 'asc');
  };

  const getSortLabel = () => {
    const option = sortOptions.find((o) => o.value === sortBy);
    return option?.label || 'Date';
  };

  return (
    <>
      <Pressable
        onPress={() => {
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
          setShowModal(true);
        }}
        className={cn(
          'px-3 py-2 rounded-full flex-row items-center',
          isDark ? 'bg-white/10' : 'bg-black/5'
        )}
      >
        <Ionicons
          name="swap-vertical"
          size={16}
          color={isDark ? '#94a3b8' : '#64748b'}
        />
        <Text
          className={cn(
            'text-sm font-medium ml-1.5',
            isDark ? 'text-slate-300' : 'text-slate-600'
          )}
        >
          {getSortLabel()}
        </Text>
        {sortOrder === 'asc' ? (
          <Ionicons name="chevron-up" size={14} color={isDark ? '#94a3b8' : '#64748b'} style={{ marginLeft: 4 }} />
        ) : (
          <Ionicons name="chevron-down" size={14} color={isDark ? '#94a3b8' : '#64748b'} style={{ marginLeft: 4 }} />
        )}
      </Pressable>

      <Modal
        visible={showModal}
        transparent
        animationType="fade"
        onRequestClose={() => setShowModal(false)}
      >
        <Pressable
          className="flex-1 bg-black/50"
          onPress={() => setShowModal(false)}
        >
          <View className="flex-1 justify-end">
            <Pressable onPress={(e) => e.stopPropagation()}>
              <View
                className={cn(
                  'rounded-t-3xl pb-8',
                  isDark ? 'bg-slate-900' : 'bg-white'
                )}
                style={{ paddingTop: 20 }}
              >
                <View className="items-center mb-4">
                  <View
                    className={cn(
                      'w-12 h-1 rounded-full mb-2',
                      isDark ? 'bg-white/20' : 'bg-black/20'
                    )}
                  />
                  <Text
                    className={cn(
                      'text-lg font-semibold',
                      isDark ? 'text-white' : 'text-slate-900'
                    )}
                  >
                    Sort By
                  </Text>
                </View>

                {sortOptions.map((option) => (
                  <Pressable
                    key={option.value}
                    onPress={() => handleSortOptionSelect(option.value)}
                    className={cn(
                      'flex-row items-center px-6 py-4',
                      sortBy === option.value && (isDark ? 'bg-white/10' : 'bg-black/5')
                    )}
                  >
                    <View className="mr-3">{option.icon}</View>
                    <Text
                      className={cn(
                        'flex-1 text-base',
                        sortBy === option.value
                          ? isDark
                            ? 'text-white font-semibold'
                            : 'text-slate-900 font-semibold'
                          : isDark
                          ? 'text-slate-300'
                          : 'text-slate-600'
                      )}
                    >
                      {option.label}
                    </Text>
                    {sortBy === option.value && (
                      <View className="ml-2">
                        {sortOrder === 'asc' ? (
                          <Ionicons name="chevron-up" size={18} color={isDark ? '#60a5fa' : '#3b82f6'} />
                        ) : (
                          <Ionicons name="chevron-down" size={18} color={isDark ? '#60a5fa' : '#3b82f6'} />
                        )}
                      </View>
                    )}
                  </Pressable>
                ))}

                <Pressable
                  onPress={handleOrderToggle}
                  className={cn(
                    'flex-row items-center justify-center px-6 py-4 mt-2 mx-4 rounded-xl',
                    isDark ? 'bg-white/10' : 'bg-black/5'
                  )}
                >
                  {sortOrder === 'asc' ? (
                    <Ionicons name="chevron-up" size={18} color={isDark ? '#60a5fa' : '#3b82f6'} />
                  ) : (
                    <Ionicons name="chevron-down" size={18} color={isDark ? '#60a5fa' : '#3b82f6'} />
                  )}
                  <Text
                    className={cn(
                      'text-base font-medium ml-2',
                      isDark ? 'text-white' : 'text-slate-900'
                    )}
                  >
                    {sortOrder === 'asc' ? 'Ascending' : 'Descending'}
                  </Text>
                </Pressable>
              </View>
            </Pressable>
          </View>
        </Pressable>
      </Modal>
    </>
  );
}
