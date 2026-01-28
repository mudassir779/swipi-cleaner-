import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  Pressable,
  FlatList,
  Dimensions,
  ActivityIndicator,
} from 'react-native';
import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore, formatBytes } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  FadeIn,
  FadeOut,
  Layout,
} from 'react-native-reanimated';
import { Ionicons, Feather } from '@expo/vector-icons';
import { cn } from '@/lib/cn';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');
const NUM_COLUMNS = 3;
const SPACING = 3;
const ITEM_SIZE = (width - SPACING * (NUM_COLUMNS + 1) - 32) / NUM_COLUMNS;

interface QueuePhotoItemProps {
  item: MediaLibrary.Asset;
  onRemove: () => void;
  isDark: boolean;
}

function QueuePhotoItem({ item, onRemove, isDark }: QueuePhotoItemProps) {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const handlePressIn = () => {
    scale.value = withSpring(0.95, { damping: 15 });
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
  };

  return (
    <Animated.View
      entering={FadeIn.duration(200)}
      exiting={FadeOut.duration(150)}
      layout={Layout.springify()}
      style={{
        width: ITEM_SIZE,
        height: ITEM_SIZE,
        margin: SPACING / 2,
      }}
    >
      <Pressable
        onPress={onRemove}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        className="flex-1"
      >
        <Animated.View style={[{ flex: 1 }, animatedStyle]}>
          <Image
            source={{ uri: item.uri }}
            style={{
              width: '100%',
              height: '100%',
              borderRadius: 8,
            }}
            contentFit="cover"
            transition={200}
          />
          {/* Red overlay */}
          <View className="absolute inset-0 rounded-lg bg-red-500/20" />

          {/* Remove button */}
          <View className="absolute top-1.5 right-1.5">
            <View className="w-6 h-6 rounded-full bg-black/60 items-center justify-center">
              <Ionicons name="close" size={14} color="#fff" />
            </View>
          </View>
        </Animated.View>
      </Pressable>
    </Animated.View>
  );
}

export default function QueueScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [queuedPhotos, setQueuedPhotos] = useState<MediaLibrary.Asset[]>([]);
  const [loading, setLoading] = useState(true);
  const [estimatedSize, setEstimatedSize] = useState(0);

  const deleteQueue = useGalleryStore((s) => s.deleteQueue);
  const removeFromDeleteQueue = useGalleryStore((s) => s.removeFromDeleteQueue);
  const clearDeleteQueue = useGalleryStore((s) => s.clearDeleteQueue);

  const deleteCount = deleteQueue.length;

  const loadQueuedPhotos = async () => {
    if (deleteQueue.length === 0) {
      setQueuedPhotos([]);
      setEstimatedSize(0);
      setLoading(false);
      return;
    }

    try {
      const assets: MediaLibrary.Asset[] = [];
      let totalSize = 0;

      for (const id of deleteQueue) {
        const assetInfo = await MediaLibrary.getAssetInfoAsync(id);
        if (assetInfo) {
          assets.push(assetInfo);
          // Use actual file size if available, otherwise estimate
          const fileSize = (assetInfo as any).fileSize;
          if (fileSize && fileSize > 0) {
            totalSize += fileSize;
          } else {
            // Fallback estimate: ~2MB per photo
            totalSize += 2 * 1024 * 1024;
          }
        }
      }

      setQueuedPhotos(assets);
      setEstimatedSize(totalSize);
    } catch (error) {
      console.error('Error loading queued photos:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadQueuedPhotos();
  }, [deleteQueue]);

  const handleRemoveFromQueue = useCallback(
    (photoId: string) => {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      removeFromDeleteQueue(photoId);
    },
    [removeFromDeleteQueue]
  );

  const handleReviewAndDelete = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    router.push('/confirm-delete');
  };

  const handleClearAll = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    clearDeleteQueue();
  };

  const renderPhoto = useCallback(
    ({ item }: { item: MediaLibrary.Asset }) => (
      <QueuePhotoItem
        item={item}
        onRemove={() => handleRemoveFromQueue(item.id)}
        isDark={isDark}
      />
    ),
    [handleRemoveFromQueue, isDark]
  );

  const keyExtractor = useCallback((item: MediaLibrary.Asset) => item.id, []);

  if (loading) {
    return (
      <View
        className={cn(
          'flex-1 items-center justify-center',
          isDark ? 'bg-black' : 'bg-slate-50'
        )}
      >
        <ActivityIndicator size="large" color={isDark ? '#60a5fa' : '#3b82f6'} />
      </View>
    );
  }

  return (
    <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-slate-50')}>
      {/* Header */}
      <View
        className={cn(
          'px-4 pb-3 border-b',
          isDark ? 'bg-black border-white/10' : 'bg-slate-50 border-black/5'
        )}
        style={{ paddingTop: insets.top + 12 }}
      >
        <View className="flex-row items-center justify-between">
          <View>
            <Text
              className={cn(
                'text-2xl font-bold',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              Delete Queue
            </Text>
            {deleteCount > 0 && (
              <Text
                className={cn(
                  'text-sm mt-0.5',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                {deleteCount} photos · ~{formatBytes(estimatedSize)} will be freed
              </Text>
            )}
          </View>

          {deleteCount > 0 && (
            <Pressable
              onPress={handleClearAll}
              className={cn(
                'px-3 py-2 rounded-full',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <Text
                className={cn(
                  'text-sm font-medium',
                  isDark ? 'text-slate-300' : 'text-slate-600'
                )}
              >
                Clear All
              </Text>
            </Pressable>
          )}
        </View>
      </View>

      {deleteCount === 0 ? (
        /* Empty State */
        <View className="flex-1 items-center justify-center px-8">
          <View
            className={cn(
              'w-20 h-20 rounded-full items-center justify-center mb-6',
              isDark ? 'bg-white/5' : 'bg-black/5'
            )}
          >
            <Ionicons
              name="archive"
              size={36}
              color={isDark ? '#475569' : '#94a3b8'}
              strokeWidth={1.5}
            />
          </View>
          <Text
            className={cn(
              'text-xl font-semibold text-center mb-2',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            Queue is Empty
          </Text>
          <Text
            className={cn(
              'text-base text-center',
              isDark ? 'text-slate-500' : 'text-slate-400'
            )}
          >
            Select photos from your library to add them to the delete queue
          </Text>
        </View>
      ) : (
        <>
          {/* Tap hint */}
          <View
            className={cn(
              'mx-4 mt-4 px-4 py-3 rounded-xl flex-row items-center',
              isDark ? 'bg-white/5' : 'bg-black/[0.03]'
            )}
          >
            <Ionicons name="close" size={16} color={isDark ? '#94a3b8' : '#64748b'} />
            <Text
              className={cn(
                'text-sm ml-2',
                isDark ? 'text-slate-400' : 'text-slate-500'
              )}
            >
              Tap a photo to remove it from the queue
            </Text>
          </View>

          {/* Photo Grid */}
          <FlatList
            data={queuedPhotos}
            renderItem={renderPhoto}
            keyExtractor={keyExtractor}
            numColumns={NUM_COLUMNS}
            contentContainerStyle={{
              paddingHorizontal: 16,
              paddingTop: 16,
              paddingBottom: insets.bottom + 120,
            }}
            showsVerticalScrollIndicator={false}
          />

          {/* Review & Delete Button */}
          <View
            className="absolute bottom-0 left-0 right-0 px-4"
            style={{ paddingBottom: insets.bottom + 90 }}
          >
            <Pressable
              onPress={handleReviewAndDelete}
              className="active:scale-[0.98] active:opacity-90"
            >
              <LinearGradient
                colors={['#ef4444', '#dc2626']}
                style={{
                  paddingVertical: 18,
                  borderRadius: 16,
                  alignItems: 'center',
                  flexDirection: 'row',
                  justifyContent: 'center',
                  shadowColor: '#ef4444',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.3,
                  shadowRadius: 12,
                }}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
              >
                <Feather name="trash-2" size={20} color="#fff" />
                <Text className="text-white text-lg font-semibold ml-2">
                  Review & Delete
                </Text>
              </LinearGradient>
            </Pressable>
          </View>
        </>
      )}
    </View>
  );
}
