import React, { useCallback, useEffect, useState, useRef } from 'react';
import {
  View,
  Text,
  Pressable,
  FlatList,
  Dimensions,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
  Extrapolation,
  useAnimatedScrollHandler,
  FadeIn,
  FadeInDown,
} from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { BlurView } from 'expo-blur';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { cn } from '@/lib/cn';
import { ModernSearchBar } from '@/components/ModernSearchBar';
import { AnimatedCounter } from '@/components/AnimatedCounter';
import { PhotoCard } from '@/components/PhotoCard';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { usePhotoSearch } from '@/lib/hooks/usePhotoSearch';
import { DateRangeFilter } from '@/components/DateRangeFilter';
import { SortMenu } from '@/components/SortMenu';
import { AdvancedFilters } from '@/components/AdvancedFilters';
import { isWithinInterval } from 'date-fns';

const { width } = Dimensions.get('window');
const NUM_COLUMNS = 3;
const SPACING = 4;
const ITEM_SIZE = (width - SPACING * (NUM_COLUMNS + 1) - 32) / NUM_COLUMNS;

export default function LibraryScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [photos, setPhotos] = useState<MediaLibrary.Asset[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [endCursor, setEndCursor] = useState<string | undefined>(undefined);
  const [searchQuery, setSearchQuery] = useState('');

  const deleteQueue = useGalleryStore((s) => s.deleteQueue);
  const toggleInDeleteQueue = useGalleryStore((s) => s.toggleInDeleteQueue);
  const isSelectionMode = useGalleryStore((s) => s.isSelectionMode);
  const setSelectionMode = useGalleryStore((s) => s.setSelectionMode);
  const setTotalPhotos = useGalleryStore((s) => s.setTotalPhotos);
  const setSwipeMode = useGalleryStore((s) => s.setSwipeMode);
  const setCurrentSwipeIndex = useGalleryStore((s) => s.setCurrentSwipeIndex);
  const dateFilter = useGalleryStore((s) => s.dateFilter);
  const setDateFilter = useGalleryStore((s) => s.setDateFilter);
  const selectAll = useGalleryStore((s) => s.selectAll);
  const deselectAll = useGalleryStore((s) => s.deselectAll);
  const invertSelection = useGalleryStore((s) => s.invertSelection);
  const sortBy = useGalleryStore((s) => s.sortBy);
  const sortOrder = useGalleryStore((s) => s.sortOrder);
  const setSortBy = useGalleryStore((s) => s.setSortBy);
  const setSortOrder = useGalleryStore((s) => s.setSortOrder);
  const photoTypeFilter = useGalleryStore((s) => s.photoTypeFilter);
  const sizeFilter = useGalleryStore((s) => s.sizeFilter);
  const setPhotoTypeFilter = useGalleryStore((s) => s.setPhotoTypeFilter);
  const setSizeFilter = useGalleryStore((s) => s.setSizeFilter);

  const deleteCount = deleteQueue.length;
  const bottomSheetRef = useRef<BottomSheet>(null);
  const snapPoints = ['50%', '85%'];

  // Animation values
  const scrollY = useSharedValue(0);
  const headerOpacity = useSharedValue(1);
  const headerTranslateY = useSharedValue(0);
  const fabScale = useSharedValue(1);
  const fabRotation = useSharedValue(0);

  // Filter photos based on search
  const searchFilteredPhotos = usePhotoSearch(photos, searchQuery);

  // Apply date filter and sorting
  const filteredPhotos = React.useMemo(() => {
    let filtered = searchFilteredPhotos;

    if (dateFilter.preset !== 'all' && dateFilter.startDate && dateFilter.endDate) {
      const startDate = new Date(dateFilter.startDate);
      const endDate = new Date(dateFilter.endDate);
      filtered = filtered.filter((photo) => {
        const photoDate = new Date(photo.creationTime);
        return isWithinInterval(photoDate, { start: startDate, end: endDate });
      });
    }

    if (photoTypeFilter !== 'all') {
      filtered = filtered.filter((photo) => {
        const filename = (photo.filename || '').toLowerCase();
        switch (photoTypeFilter) {
          case 'screenshots':
            return filename.includes('screenshot') || filename.includes('screen shot');
          case 'selfies':
            return photo.width === photo.height || (Math.abs(photo.width - photo.height) < 100);
          case 'live':
            return (photo as any).mediaSubtypes?.includes('photoLive') || false;
          case 'burst':
            return (photo as any).mediaSubtypes?.includes('photoBurst') || false;
          default:
            return true;
        }
      });
    }

    if (sizeFilter !== 'all') {
      filtered = filtered.filter((photo) => {
        const fileSize = (photo as any).fileSize || 0;
        const sizeInMB = fileSize / (1024 * 1024);
        switch (sizeFilter) {
          case 'large':
            return sizeInMB > 10;
          case 'medium':
            return sizeInMB >= 1 && sizeInMB <= 10;
          case 'small':
            return sizeInMB < 1;
          default:
            return true;
        }
      });
    }

    const sorted = [...filtered].sort((a, b) => {
      let comparison = 0;
      switch (sortBy) {
        case 'date':
          comparison = a.creationTime - b.creationTime;
          break;
        case 'size':
          const sizeA = (a as any).fileSize || 0;
          const sizeB = (b as any).fileSize || 0;
          comparison = sizeA - sizeB;
          break;
        case 'name':
          const nameA = a.filename || '';
          const nameB = b.filename || '';
          comparison = nameA.localeCompare(nameB);
          break;
      }
      return sortOrder === 'asc' ? comparison : -comparison;
    });

    return sorted;
  }, [searchFilteredPhotos, dateFilter, sortBy, sortOrder, photoTypeFilter, sizeFilter]);

  const loadPhotos = async (cursor?: string) => {
    try {
      const { status } = await MediaLibrary.getPermissionsAsync();
      if (status !== 'granted') {
        router.replace('/onboarding');
        return;
      }

      const result = await MediaLibrary.getAssetsAsync({
        first: 40,
        after: cursor,
        mediaType: 'photo',
        sortBy: [MediaLibrary.SortBy.creationTime],
      });

      const photosWithSizes = await Promise.all(
        result.assets.map(async (asset) => {
          try {
            const info = await MediaLibrary.getAssetInfoAsync(asset.id);
            return {
              ...asset,
              fileSize: (info as any)?.fileSize || 0,
            };
          } catch {
            return { ...asset, fileSize: 0 };
          }
        })
      );

      if (cursor) {
        setPhotos((prev) => [...prev, ...photosWithSizes]);
      } else {
        setPhotos(photosWithSizes);
        setTotalPhotos(result.totalCount);
      }

      setHasMore(result.hasNextPage);
      setEndCursor(result.endCursor);
    } catch (error) {
      console.error('Error loading photos:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
      setLoadingMore(false);
    }
  };

  useEffect(() => {
    loadPhotos();
  }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    loadPhotos();
  }, []);

  const loadMorePhotos = () => {
    if (hasMore && !loadingMore && endCursor) {
      setLoadingMore(true);
      loadPhotos(endCursor);
    }
  };

  // Scroll handler for parallax
  const scrollHandler = useAnimatedScrollHandler({
    onScroll: (event) => {
      scrollY.value = event.contentOffset.y;
      headerOpacity.value = interpolate(
        event.contentOffset.y,
        [0, 100],
        [1, 0.95],
        Extrapolation.CLAMP
      );
      headerTranslateY.value = interpolate(
        event.contentOffset.y,
        [0, 100],
        [0, -20],
        Extrapolation.CLAMP
      );
    },
  });

  const headerAnimatedStyle = useAnimatedStyle(() => ({
    opacity: headerOpacity.value,
    transform: [{ translateY: headerTranslateY.value }],
  }));

  const handlePhotoPress = useCallback(
    (photoId: string) => {
      if (isSelectionMode) {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        toggleInDeleteQueue(photoId);
      } else {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        const photoIds = photos.map((p) => p.id).join(',');
        router.push({
          pathname: '/photo-details',
          params: { id: photoId, photoIds },
        });
      }
    },
    [isSelectionMode, toggleInDeleteQueue, photos, router]
  );

  const handlePhotoLongPress = useCallback(
    (photoId: string) => {
      if (!isSelectionMode) {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
        setSelectionMode(true);
        toggleInDeleteQueue(photoId);
      }
    },
    [isSelectionMode, setSelectionMode, toggleInDeleteQueue]
  );

  const handleToggleSelectionMode = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSelectionMode(!isSelectionMode);
  };

  const handleSwipeMode = () => {
    if (photos.length > 0) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      setCurrentSwipeIndex(0);
      setSwipeMode(true);
      router.push('/swipe-review');
    }
  };

  const handleSelectAll = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    const photoIds = filteredPhotos.map((p) => p.id);
    selectAll(photoIds);
  };

  const handleDeselectAll = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    deselectAll();
  };

  const handleInvertSelection = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    const photoIds = filteredPhotos.map((p) => p.id);
    invertSelection(photoIds);
  };

  const handleOpenFilters = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    bottomSheetRef.current?.expand();
  };

  const renderPhoto = useCallback(
    ({ item, index }: { item: MediaLibrary.Asset; index: number }) => (
      <Animated.View
        entering={FadeInDown.delay(index % 20).duration(400).springify()}
      >
        <PhotoCard
          item={item}
          isSelected={deleteQueue.includes(item.id)}
          isSelectionMode={isSelectionMode}
          onPress={() => handlePhotoPress(item.id)}
          onLongPress={() => handlePhotoLongPress(item.id)}
          index={index}
        />
      </Animated.View>
    ),
    [deleteQueue, isSelectionMode, handlePhotoPress, handlePhotoLongPress]
  );

  const keyExtractor = useCallback((item: MediaLibrary.Asset) => item.id, []);

  // FAB animation
  useEffect(() => {
    fabScale.value = withSpring(1, { damping: 15 });
    fabRotation.value = withSpring(0, { damping: 15 });
  }, []);

  const fabAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      { scale: fabScale.value },
      { rotate: `${fabRotation.value}deg` },
    ],
  }));

  const handleFABPress = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    fabScale.value = withSpring(0.9, { damping: 15 }, () => {
      fabScale.value = withSpring(1, { damping: 15 });
    });
    fabRotation.value = withSpring(45, { damping: 15 }, () => {
      fabRotation.value = withSpring(0, { damping: 15 });
    });
    handleOpenFilters();
  };

  if (loading) {
    return (
      <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-slate-50')}>
        <LinearGradient
          colors={
            isDark
              ? ['#0a0a0a', '#1a1a2e', '#16213e']
              : ['#f8fafc', '#e2e8f0', '#cbd5e1']
          }
          style={{ flex: 1 }}
        >
          <View
            style={{ paddingTop: Math.max(insets.top, 44) + 20 }}
            className="px-4 pb-4"
          >
            <SkeletonLoader />
          </View>
        </LinearGradient>
      </View>
    );
  }

  return (
    <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-slate-50')}>
      <Animated.FlatList
        data={filteredPhotos}
        renderItem={renderPhoto}
        keyExtractor={keyExtractor}
        numColumns={NUM_COLUMNS}
        contentContainerStyle={{
          paddingHorizontal: SPACING / 2,
          paddingTop: 280,
          paddingBottom: deleteCount > 0 ? 140 : insets.bottom + 100,
        }}
        onEndReached={loadMorePhotos}
        onEndReachedThreshold={0.5}
        showsVerticalScrollIndicator={false}
        onScroll={scrollHandler}
        scrollEventThrottle={16}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={isDark ? '#60a5fa' : '#3b82f6'}
            colors={[isDark ? '#60a5fa' : '#3b82f6']}
          />
        }
        ListHeaderComponent={
          <Animated.View style={headerAnimatedStyle}>
            {/* Gradient Header */}
            <LinearGradient
              colors={
                isDark
                  ? ['#0a0a0a', '#1a1a2e', '#16213e']
                  : ['#f8fafc', '#e2e8f0', '#cbd5e1']
              }
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                height: 280,
                paddingTop: Math.max(insets.top, 44) + 8,
              }}
              pointerEvents="none"
            >
              <View className="px-4 pb-4" pointerEvents="box-none">
                {/* Title Section */}
                <View className="flex-row items-center justify-between mb-4">
                  <View className="flex-1">
                    <Text
                      className={cn(
                        'text-4xl font-bold mb-2',
                        isDark ? 'text-white' : 'text-slate-900'
                      )}
                      style={{ lineHeight: 44 }}
                    >
                      Gallery
                    </Text>
                    <View className="flex-row items-center">
                      <AnimatedCounter
                        value={filteredPhotos.length}
                        className={cn(isDark ? 'text-blue-400' : 'text-blue-600')}
                      />
                      <Text
                        className={cn(
                          'text-lg ml-2',
                          isDark ? 'text-slate-400' : 'text-slate-500'
                        )}
                      >
                        photos
                      </Text>
                    </View>
                  </View>

                  {/* Quick Actions */}
                  <View className="flex-row gap-2">
                    <Pressable
                      onPress={handleOpenFilters}
                      className={cn(
                        'w-12 h-12 rounded-2xl items-center justify-center',
                        isDark ? 'bg-white/10' : 'bg-white/80'
                      )}
                    >
                      <Ionicons
                        name="filter"
                        size={20}
                        color={isDark ? '#60a5fa' : '#3b82f6'}
                      />
                    </Pressable>
                    {!isSelectionMode && (
                      <Pressable
                        onPress={handleSwipeMode}
                        className={cn(
                          'w-12 h-12 rounded-2xl items-center justify-center',
                          isDark ? 'bg-white/10' : 'bg-white/80'
                        )}
                      >
                        <MaterialIcons
                          name="layers"
                          size={20}
                          color={isDark ? '#60a5fa' : '#3b82f6'}
                        />
                      </Pressable>
                    )}
                  </View>
                </View>

                {/* Search Bar */}
                <ModernSearchBar
                  value={searchQuery}
                  onChangeText={setSearchQuery}
                  onClear={() => setSearchQuery('')}
                />

                {/* Batch Operations Bar */}
                {isSelectionMode && filteredPhotos.length > 0 && (
                  <Animated.View
                    entering={FadeIn.duration(300)}
                    className="flex-row items-center gap-2 mt-3"
                  >
                    <Pressable
                      onPress={handleSelectAll}
                      className={cn(
                        'flex-1 flex-row items-center justify-center px-4 py-3 rounded-xl',
                        isDark ? 'bg-white/10' : 'bg-white/80'
                      )}
                    >
                      <Ionicons
                        name="checkbox"
                        size={18}
                        color={isDark ? '#60a5fa' : '#3b82f6'}
                      />
                      <Text
                        className={cn(
                          'text-sm font-semibold ml-2',
                          isDark ? 'text-white' : 'text-slate-900'
                        )}
                      >
                        Select All
                      </Text>
                    </Pressable>

                    <Pressable
                      onPress={handleDeselectAll}
                      className={cn(
                        'flex-1 flex-row items-center justify-center px-4 py-3 rounded-xl',
                        isDark ? 'bg-white/10' : 'bg-white/80'
                      )}
                    >
                      <Ionicons
                        name="square-outline"
                        size={18}
                        color={isDark ? '#60a5fa' : '#3b82f6'}
                      />
                      <Text
                        className={cn(
                          'text-sm font-semibold ml-2',
                          isDark ? 'text-white' : 'text-slate-900'
                        )}
                      >
                        Clear
                      </Text>
                    </Pressable>

                    <Pressable
                      onPress={handleToggleSelectionMode}
                      className={cn(
                        'px-4 py-3 rounded-xl',
                        isDark ? 'bg-blue-500' : 'bg-blue-600'
                      )}
                    >
                      <Text className="text-white text-sm font-semibold">Done</Text>
                    </Pressable>
                  </Animated.View>
                )}
              </View>
            </LinearGradient>
          </Animated.View>
        }
        ListFooterComponent={
          loadingMore ? (
            <View className="py-6 items-center">
              <ActivityIndicator
                size="small"
                color={isDark ? '#60a5fa' : '#3b82f6'}
              />
            </View>
          ) : null
        }
        ListEmptyComponent={
          <View className="flex-1 items-center justify-center py-20 px-8">
            <View
              className={cn(
                'w-24 h-24 rounded-full items-center justify-center mb-6',
                isDark ? 'bg-white/5' : 'bg-black/5'
              )}
            >
              <MaterialIcons
                name="auto-awesome"
                size={40}
                color={isDark ? '#94a3b8' : '#64748b'}
              />
            </View>
            <Text
              className={cn(
                'text-xl font-semibold text-center mb-2',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              No photos found
            </Text>
            <Text
              className={cn(
                'text-base text-center',
                isDark ? 'text-slate-500' : 'text-slate-400'
              )}
            >
              Try adjusting your filters or search query
            </Text>
          </View>
        }
      />

      {/* Delete Queue Indicator */}
      {deleteCount > 0 && (
        <Animated.View
          entering={FadeIn.duration(300)}
          className="absolute bottom-0 left-0 right-0"
          style={{ paddingBottom: insets.bottom + 80 }}
        >
          <Pressable
            onPress={() => router.push('/(tabs)/queue')}
            className="mx-4"
          >
            <LinearGradient
              colors={['#ef4444', '#dc2626']}
              className="flex-row items-center justify-between px-6 py-4 rounded-2xl"
              style={{
                shadowColor: '#ef4444',
                shadowOffset: { width: 0, height: 8 },
                shadowOpacity: 0.4,
                shadowRadius: 16,
              }}
            >
              <View className="flex-row items-center">
                <MaterialIcons name="auto-awesome" size={20} color="#fff" />
                <Text className="text-white font-bold text-lg ml-3">
                  {deleteCount} selected
                </Text>
              </View>
              <Text className="text-white/90 text-base font-medium">
                Review →
              </Text>
            </LinearGradient>
          </Pressable>
        </Animated.View>
      )}

      {/* Floating Action Button */}
      {!isSelectionMode && (
        <Animated.View
          style={[
            fabAnimatedStyle,
            {
              position: 'absolute',
              bottom: deleteCount > 0 ? 140 : insets.bottom + 20,
              right: 20,
            },
          ]}
        >
          <Pressable onPress={handleFABPress}>
            <LinearGradient
              colors={['#3b82f6', '#2563eb']}
              className="w-16 h-16 rounded-full items-center justify-center"
              style={{
                shadowColor: '#3b82f6',
                shadowOffset: { width: 0, height: 8 },
                shadowOpacity: 0.4,
                shadowRadius: 16,
              }}
            >
              <Ionicons name="add" size={28} color="#fff" />
            </LinearGradient>
          </Pressable>
        </Animated.View>
      )}

      {/* Bottom Sheet for Filters */}
      <BottomSheet
        ref={bottomSheetRef}
        index={-1}
        snapPoints={snapPoints}
        enablePanDownToClose
        backgroundStyle={{
          backgroundColor: isDark ? '#1e293b' : '#ffffff',
        }}
        handleIndicatorStyle={{
          backgroundColor: isDark ? '#475569' : '#cbd5e1',
        }}
      >
        <BottomSheetView
          style={{
            flex: 1,
            paddingHorizontal: 20,
            paddingTop: 10,
          }}
        >
          <View className="flex-row items-center justify-between mb-6">
            <Text
              className={cn(
                'text-2xl font-bold',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              Filters & Sort
            </Text>
            <Pressable
              onPress={() => bottomSheetRef.current?.close()}
              className={cn(
                'w-10 h-10 rounded-full items-center justify-center',
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

          <View className="space-y-6">
            {/* Sort */}
            <View>
              <Text
                className={cn(
                  'text-sm font-semibold mb-3',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                SORT BY
              </Text>
              <SortMenu
                sortBy={sortBy}
                sortOrder={sortOrder}
                onSortChange={(newSortBy, newSortOrder) => {
                  setSortBy(newSortBy);
                  setSortOrder(newSortOrder);
                }}
              />
            </View>

            {/* Date Filter */}
            <View>
              <Text
                className={cn(
                  'text-sm font-semibold mb-3',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                DATE RANGE
              </Text>
              <DateRangeFilter
                filter={{
                  preset: dateFilter.preset,
                  startDate: dateFilter.startDate
                    ? new Date(dateFilter.startDate)
                    : undefined,
                  endDate: dateFilter.endDate
                    ? new Date(dateFilter.endDate)
                    : undefined,
                }}
                onFilterChange={(filter) => {
                  setDateFilter({
                    preset: filter.preset,
                    startDate: filter.startDate?.getTime(),
                    endDate: filter.endDate?.getTime(),
                  });
                }}
              />
            </View>

            {/* Advanced Filters */}
            <View>
              <Text
                className={cn(
                  'text-sm font-semibold mb-3',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                FILTERS
              </Text>
              <AdvancedFilters
                photoTypeFilter={photoTypeFilter}
                sizeFilter={sizeFilter}
                onPhotoTypeChange={setPhotoTypeFilter}
                onSizeChange={setSizeFilter}
              />
            </View>
          </View>
        </BottomSheetView>
      </BottomSheet>
    </View>
  );
}
