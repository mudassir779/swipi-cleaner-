import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  Pressable,
  FlatList,
  Dimensions,
  Image,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore, formatBytes } from '@/lib/state/gallery-store';
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
import { format, differenceInDays } from 'date-fns';

const { width } = Dimensions.get('window');
const NUM_COLUMNS = 3;
const SPACING = 3;
const ITEM_SIZE = (width - SPACING * (NUM_COLUMNS + 1) - 32) / NUM_COLUMNS;

interface RecentlyDeletedItemProps {
  item: { id: string; deletedAt: number; asset: any };
  onRestore: () => void;
  onPermanentDelete: () => void;
  isDark: boolean;
}

function RecentlyDeletedItem({
  item,
  onRestore,
  onPermanentDelete,
  isDark,
}: RecentlyDeletedItemProps) {
  const scale = useSharedValue(1);
  const daysSinceDeleted = differenceInDays(Date.now(), item.deletedAt);
  const daysRemaining = Math.max(0, 30 - daysSinceDeleted);

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
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        className="flex-1"
      >
        <Animated.View style={[{ flex: 1 }, animatedStyle]}>
          <Image
            source={{ uri: item.asset.uri }}
            style={{
              width: '100%',
              height: '100%',
              borderRadius: 8,
            }}
            resizeMode="cover"
          />
          {/* Overlay */}
          <View className="absolute inset-0 rounded-lg bg-black/40" />
          
          {/* Days remaining badge */}
          <View className="absolute top-2 left-2">
            <View className="flex-row items-center px-2 py-1 rounded-full bg-black/60">
              <Ionicons name="time" size={12} color="#fff" />
              <Text className="text-white text-xs font-medium ml-1">
                {daysRemaining}d
              </Text>
            </View>
          </View>

          {/* Action buttons */}
          <View className="absolute bottom-2 left-2 right-2 flex-row gap-1">
            <Pressable
              onPress={onRestore}
              className="flex-1 bg-green-500/90 rounded-lg px-2 py-1.5 items-center"
            >
              <Ionicons name="refresh" size={14} color="#fff" />
            </Pressable>
            <Pressable
              onPress={onPermanentDelete}
              className="flex-1 bg-red-500/90 rounded-lg px-2 py-1.5 items-center"
            >
              <Feather name="trash-2" size={14} color="#fff" />
            </Pressable>
          </View>
        </Animated.View>
      </Pressable>
    </Animated.View>
  );
}

export default function RecentlyDeletedScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const recentlyDeleted = useGalleryStore((s) => s.recentlyDeleted);
  const removeFromRecentlyDeleted = useGalleryStore((s) => s.removeFromRecentlyDeleted);
  const clearRecentlyDeleted = useGalleryStore((s) => s.clearRecentlyDeleted);
  const restorePhoto = useGalleryStore((s) => s.restorePhoto);

  // Auto-delete photos older than 30 days
  useEffect(() => {
    const now = Date.now();
    const thirtyDaysAgo = now - 30 * 24 * 60 * 60 * 1000;
    
    recentlyDeleted.forEach((item) => {
      if (item.deletedAt < thirtyDaysAgo) {
        removeFromRecentlyDeleted(item.id);
      }
    });
  }, [recentlyDeleted, removeFromRecentlyDeleted]);

  const handleRestore = useCallback(
    (id: string) => {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      Alert.alert(
        'Restore Photo',
        'Note: Photos deleted through this app cannot be restored through the Media Library API. They may still be available in your device\'s Recently Deleted album.',
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'OK',
            onPress: () => {
              restorePhoto(id);
              removeFromRecentlyDeleted(id);
            },
          },
        ]
      );
    },
    [restorePhoto, removeFromRecentlyDeleted]
  );

  const handlePermanentDelete = useCallback(
    (id: string) => {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      Alert.alert(
        'Permanently Delete',
        'This will remove the photo from your recently deleted list. The photo may still be recoverable from your device\'s Recently Deleted album.',
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'Delete',
            style: 'destructive',
            onPress: () => {
              removeFromRecentlyDeleted(id);
            },
          },
        ]
      );
    },
    [removeFromRecentlyDeleted]
  );

  const handleClearAll = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    Alert.alert(
      'Clear All',
      'This will remove all photos from recently deleted.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Clear',
          style: 'destructive',
          onPress: () => {
            clearRecentlyDeleted();
          },
        },
      ]
    );
  };

  const renderItem = useCallback(
    ({ item }: { item: { id: string; deletedAt: number; asset: any } }) => (
      <RecentlyDeletedItem
        item={item}
        onRestore={() => handleRestore(item.id)}
        onPermanentDelete={() => handlePermanentDelete(item.id)}
        isDark={isDark}
      />
    ),
    [handleRestore, handlePermanentDelete, isDark]
  );

  const keyExtractor = useCallback(
    (item: { id: string; deletedAt: number; asset: any }) => item.id,
    []
  );

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
          <View className="flex-row items-center">
            <Pressable
              onPress={() => router.back()}
              className={cn(
                'w-10 h-10 rounded-full items-center justify-center mr-3',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <Ionicons
                name="chevron-back"
                size={24}
                color={isDark ? '#fff' : '#1e293b'}
              />
            </Pressable>
            <View>
              <Text
                className={cn(
                  'text-2xl font-bold',
                  isDark ? 'text-white' : 'text-slate-900'
                )}
              >
                Recently Deleted
              </Text>
              {recentlyDeleted.length > 0 && (
                <Text
                  className={cn(
                    'text-sm mt-0.5',
                    isDark ? 'text-slate-400' : 'text-slate-500'
                  )}
                >
                  {recentlyDeleted.length} photos · Auto-deletes after 30 days
                </Text>
              )}
            </View>
          </View>

          {recentlyDeleted.length > 0 && (
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

      {recentlyDeleted.length === 0 ? (
        <View className="flex-1 items-center justify-center px-8">
          <View
            className={cn(
              'w-20 h-20 rounded-full items-center justify-center mb-6',
              isDark ? 'bg-white/5' : 'bg-black/5'
            )}
          >
            <Feather
              name="trash-2"
              size={36}
              color={isDark ? '#475569' : '#94a3b8'}
            />
          </View>
          <Text
            className={cn(
              'text-xl font-semibold text-center mb-2',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            No Recently Deleted Photos
          </Text>
          <Text
            className={cn(
              'text-base text-center',
              isDark ? 'text-slate-500' : 'text-slate-400'
            )}
          >
            Photos you delete will appear here for 30 days before being permanently removed
          </Text>
        </View>
      ) : (
        <FlatList
          data={recentlyDeleted}
          renderItem={renderItem}
          keyExtractor={keyExtractor}
          numColumns={NUM_COLUMNS}
          contentContainerStyle={{
            paddingHorizontal: 16,
            paddingTop: 16,
            paddingBottom: insets.bottom + 20,
          }}
          showsVerticalScrollIndicator={false}
        />
      )}
    </View>
  );
}
