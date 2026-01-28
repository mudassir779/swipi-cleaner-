import React, { useState, useEffect } from 'react';
import { View, Text, Pressable, Image, Dimensions, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { DuplicateGroup as DuplicateGroupType } from '@/lib/utils/duplicateDetection';
import { getBestPhoto } from '@/lib/utils/duplicateDetection';
import { useGalleryStore } from '@/lib/state/gallery-store';
import { formatBytes } from '@/lib/state/gallery-store';
import { Ionicons, Feather, MaterialIcons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import Animated, { FadeIn, FadeOut } from 'react-native-reanimated';

const { width } = Dimensions.get('window');
const ITEM_SIZE = (width - 48) / 3;

interface DuplicateGroupProps {
  group: DuplicateGroupType;
  onSelectAll: (photoIds: string[]) => void;
  onDeselectAll: (photoIds: string[]) => void;
}

export function DuplicateGroupComponent({
  group,
  onSelectAll,
  onDeselectAll,
}: DuplicateGroupProps) {
  const router = useRouter();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [selectedPhotos, setSelectedPhotos] = useState<Set<string>>(new Set());
  const [bestPhoto] = useState(() => getBestPhoto(group));

  const addToDeleteQueue = useGalleryStore((s) => s.addToDeleteQueue);
  const removeFromDeleteQueue = useGalleryStore((s) => s.removeFromDeleteQueue);
  const isInDeleteQueue = useGalleryStore((s) => s.isInDeleteQueue);

  // Auto-select all except best photo
  useEffect(() => {
    const toSelect = group.photos
      .filter((p) => p.id !== bestPhoto.id)
      .map((p) => p.id);
    setSelectedPhotos(new Set(toSelect));
    onSelectAll(toSelect);
  }, []);

  const handleTogglePhoto = (photoId: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    const newSelected = new Set(selectedPhotos);
    if (newSelected.has(photoId)) {
      newSelected.delete(photoId);
      removeFromDeleteQueue(photoId);
    } else {
      newSelected.add(photoId);
      addToDeleteQueue(photoId);
    }
    setSelectedPhotos(newSelected);
  };

  const handleSelectAll = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    const toSelect = group.photos
      .filter((p) => p.id !== bestPhoto.id)
      .map((p) => p.id);
    setSelectedPhotos(new Set(toSelect));
    onSelectAll(toSelect);
  };

  const handleDeselectAll = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    setSelectedPhotos(new Set());
    onDeselectAll(group.photos.map((p) => p.id));
  };

  const handleCompare = () => {
    if (group.photos.length >= 2) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      router.push({
        pathname: '/photo-comparison',
        params: {
          photo1: group.photos[0].id,
          photo2: group.photos[1].id,
        },
      });
    }
  };

  const allSelected = group.photos.filter((p) => p.id !== bestPhoto.id).every((p) =>
    selectedPhotos.has(p.id)
  );

  return (
    <Animated.View
      entering={FadeIn.duration(200)}
      exiting={FadeOut.duration(150)}
      className={cn(
        'mx-4 mb-6 p-4 rounded-2xl',
        isDark ? 'bg-white/5' : 'bg-white'
      )}
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: isDark ? 0 : 0.1,
        shadowRadius: 8,
      }}
    >
      {/* Header */}
      <View className="flex-row items-center justify-between mb-3">
        <View>
          <Text
            className={cn(
              'text-base font-semibold',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            {group.photos.length} Duplicates
          </Text>
          <Text
            className={cn('text-sm mt-0.5', isDark ? 'text-slate-400' : 'text-slate-500')}
          >
            {formatBytes(group.totalSize)} total
          </Text>
        </View>

        <View className="flex-row items-center gap-2">
          {group.photos.length >= 2 && (
            <Pressable
              onPress={handleCompare}
              className={cn(
                'px-3 py-1.5 rounded-full flex-row items-center',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <MaterialIcons name="compare" size={14} color={isDark ? '#94a3b8' : '#64748b'} />
              <Text
                className={cn(
                  'text-xs font-medium ml-1.5',
                  isDark ? 'text-slate-300' : 'text-slate-600'
                )}
              >
                Compare
              </Text>
            </Pressable>
          )}
          {allSelected ? (
            <Pressable
              onPress={handleDeselectAll}
              className={cn(
                'px-3 py-1.5 rounded-full',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <Text
                className={cn(
                  'text-xs font-medium',
                  isDark ? 'text-slate-300' : 'text-slate-600'
                )}
              >
                Deselect
              </Text>
            </Pressable>
          ) : (
            <Pressable
              onPress={handleSelectAll}
              className="px-3 py-1.5 rounded-full bg-blue-500"
            >
              <Text className="text-xs font-medium text-white">Select All</Text>
            </Pressable>
          )}
        </View>
      </View>

      {/* Best Photo Indicator */}
      <View
        className={cn(
          'flex-row items-center px-3 py-2 rounded-xl mb-3',
          isDark ? 'bg-green-500/20' : 'bg-green-500/10'
        )}
      >
        <Ionicons name="checkmark" size={16} color="#22c55e" />
        <Text
          className={cn('text-sm ml-2 flex-1', isDark ? 'text-green-400' : 'text-green-600')}
        >
          Best photo (kept by default)
        </Text>
      </View>

      {/* Photo Grid */}
      <View className="flex-row flex-wrap">
        {group.photos.map((photo, index) => {
          const isSelected = selectedPhotos.has(photo.id);
          const isBest = photo.id === bestPhoto.id;

          return (
            <Pressable
              key={photo.id}
              onPress={() => !isBest && handleTogglePhoto(photo.id)}
              disabled={isBest}
              className="m-1"
              style={{ width: ITEM_SIZE, height: ITEM_SIZE }}
            >
              <View
                className={cn(
                  'flex-1 rounded-lg overflow-hidden',
                  isBest && 'border-2 border-green-500',
                  isSelected && !isBest && 'border-2 border-red-500'
                )}
              >
                <Image
                  source={{ uri: photo.uri }}
                  style={{ width: '100%', height: '100%' }}
                  resizeMode="cover"
                />

                {/* Overlay */}
                {isSelected && !isBest && (
                  <View className="absolute inset-0 bg-red-500/30 items-center justify-center">
                    <View className="w-8 h-8 rounded-full bg-red-500 items-center justify-center">
                      <Ionicons name="close" size={16} color="#fff" />
                    </View>
                  </View>
                )}

                {isBest && (
                  <View className="absolute top-1 right-1">
                    <View className="w-6 h-6 rounded-full bg-green-500 items-center justify-center">
                      <Ionicons name="checkmark" size={14} color="#fff" />
                    </View>
                  </View>
                )}
              </View>
            </Pressable>
          );
        })}
      </View>
    </Animated.View>
  );
}
