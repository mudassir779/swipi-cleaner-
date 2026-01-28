import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  Pressable,
  Dimensions,
  Image,
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
  runOnJS,
  interpolate,
  Extrapolation,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import { Ionicons, Feather } from '@expo/vector-icons';
import { cn } from '@/lib/cn';
import { LinearGradient } from 'expo-linear-gradient';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_WIDTH = SCREEN_WIDTH - 48;
const CARD_HEIGHT = SCREEN_HEIGHT * 0.6;
const SWIPE_THRESHOLD = SCREEN_WIDTH * 0.3;

export default function SwipeReviewScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [photos, setPhotos] = useState<MediaLibrary.Asset[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentIndex, setCurrentIndex] = useState(0);

  const addToDeleteQueue = useGalleryStore((s) => s.addToDeleteQueue);
  const deleteQueue = useGalleryStore((s) => s.deleteQueue);
  const setSwipeMode = useGalleryStore((s) => s.setSwipeMode);

  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const cardRotation = useSharedValue(0);

  const loadPhotos = async () => {
    try {
      const result = await MediaLibrary.getAssetsAsync({
        first: 100,
        mediaType: 'photo',
        sortBy: [[MediaLibrary.SortBy.creationTime, false]],
      });

      setPhotos(result.assets);
    } catch (error) {
      console.error('Error loading photos:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPhotos();
    return () => {
      setSwipeMode(false);
    };
  }, []);

  const handleSwipeLeft = useCallback(() => {
    // Add to delete queue
    if (photos[currentIndex]) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      addToDeleteQueue(photos[currentIndex].id);
    }
  }, [currentIndex, photos, addToDeleteQueue]);

  const handleSwipeRight = useCallback(() => {
    // Keep photo - just move to next
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  }, []);

  const moveToNext = useCallback(() => {
    if (currentIndex < photos.length - 1) {
      setCurrentIndex((prev) => prev + 1);
    }
  }, [currentIndex, photos.length]);

  const resetPosition = () => {
    translateX.value = withSpring(0, { damping: 15 });
    translateY.value = withSpring(0, { damping: 15 });
    cardRotation.value = withSpring(0, { damping: 15 });
  };

  const swipeOffScreen = (direction: 'left' | 'right') => {
    const targetX = direction === 'left' ? -SCREEN_WIDTH * 1.5 : SCREEN_WIDTH * 1.5;

    translateX.value = withTiming(targetX, { duration: 300 }, () => {
      runOnJS(direction === 'left' ? handleSwipeLeft : handleSwipeRight)();
      runOnJS(moveToNext)();
      translateX.value = 0;
      translateY.value = 0;
      cardRotation.value = 0;
    });
  };

  const panGesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX;
      translateY.value = event.translationY * 0.5;
      cardRotation.value = interpolate(
        event.translationX,
        [-SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2],
        [-15, 0, 15],
        Extrapolation.CLAMP
      );
    })
    .onEnd((event) => {
      if (Math.abs(event.translationX) > SWIPE_THRESHOLD) {
        const direction = event.translationX > 0 ? 'right' : 'left';
        runOnJS(swipeOffScreen)(direction);
      } else {
        runOnJS(resetPosition)();
      }
    });

  const cardAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
      { rotate: `${cardRotation.value}deg` },
    ],
  }));

  const leftIndicatorStyle = useAnimatedStyle(() => ({
    opacity: interpolate(
      translateX.value,
      [-SWIPE_THRESHOLD, 0],
      [1, 0],
      Extrapolation.CLAMP
    ),
  }));

  const rightIndicatorStyle = useAnimatedStyle(() => ({
    opacity: interpolate(
      translateX.value,
      [0, SWIPE_THRESHOLD],
      [0, 1],
      Extrapolation.CLAMP
    ),
  }));

  const handleClose = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSwipeMode(false);
    router.back();
  };

  const handleManualDelete = () => {
    swipeOffScreen('left');
  };

  const handleManualKeep = () => {
    swipeOffScreen('right');
  };

  const deleteCount = deleteQueue.length;
  const currentPhoto = photos[currentIndex];
  const isFinished = currentIndex >= photos.length;

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
        className="px-4 flex-row items-center justify-between"
        style={{ paddingTop: insets.top + 8 }}
      >
        <Pressable
          onPress={handleClose}
          className={cn(
            'w-10 h-10 rounded-full items-center justify-center',
            isDark ? 'bg-white/10' : 'bg-black/5'
          )}
        >
          <Ionicons
            name="chevron-down"
            size={24}
            color={isDark ? '#fff' : '#1e293b'}
          />
        </Pressable>

        <View className="items-center">
          <Text
            className={cn(
              'text-sm font-medium',
              isDark ? 'text-slate-400' : 'text-slate-500'
            )}
          >
            {currentIndex + 1} of {photos.length}
          </Text>
        </View>

        {deleteCount > 0 ? (
          <Pressable
            onPress={() => router.push('/(tabs)/queue')}
            className="flex-row items-center px-3 py-2 rounded-full bg-red-500"
          >
            <Feather name="trash-2" size={16} color="#fff" />
            <Text className="text-white text-sm font-semibold ml-1">
              {deleteCount}
            </Text>
          </Pressable>
        ) : (
          <View className="w-10" />
        )}
      </View>

      {/* Instructions */}
      <View className="items-center mt-4 px-8">
        <Text
          className={cn(
            'text-sm text-center',
            isDark ? 'text-slate-500' : 'text-slate-400'
          )}
        >
          Swipe left to delete, right to keep
        </Text>
      </View>

      {/* Card Stack */}
      <View className="flex-1 items-center justify-center">
        {isFinished ? (
          <View className="items-center px-8">
            <View
              className={cn(
                'w-20 h-20 rounded-full items-center justify-center mb-6',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <Ionicons name="checkmark" size={40} color={isDark ? '#22c55e' : '#16a34a'} />
            </View>
            <Text
              className={cn(
                'text-2xl font-bold text-center mb-2',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              All Done!
            </Text>
            <Text
              className={cn(
                'text-base text-center mb-6',
                isDark ? 'text-slate-400' : 'text-slate-500'
              )}
            >
              You've reviewed all your photos
            </Text>
            {deleteCount > 0 && (
              <Pressable
                onPress={() => router.push('/(tabs)/queue')}
                className="active:scale-[0.98]"
              >
                <LinearGradient
                  colors={['#ef4444', '#dc2626']}
                  style={{
                    paddingVertical: 16,
                    paddingHorizontal: 32,
                    borderRadius: 14,
                    flexDirection: 'row',
                    alignItems: 'center',
                  }}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 1 }}
                >
                  <Feather name="trash-2" size={18} color="#fff" />
                  <Text className="text-white font-semibold ml-2">
                    Review {deleteCount} Photos
                  </Text>
                </LinearGradient>
              </Pressable>
            )}
          </View>
        ) : (
          <>
            {/* Next card preview (behind current) */}
            {currentIndex + 1 < photos.length && photos[currentIndex + 1] && (
              <View
                className="absolute"
                style={{
                  width: CARD_WIDTH - 20,
                  height: CARD_HEIGHT - 20,
                  borderRadius: 20,
                  overflow: 'hidden',
                  opacity: 0.5,
                  transform: [{ scale: 0.95 }],
                }}
              >
                <Image
                  source={{ uri: photos[currentIndex + 1].uri }}
                  style={{ width: '100%', height: '100%' }}
                  resizeMode="cover"
                />
              </View>
            )}

            {/* Current card */}
            {currentPhoto && (
              <GestureDetector gesture={panGesture}>
                <Animated.View
                  style={[
                    cardAnimatedStyle,
                    {
                      width: CARD_WIDTH,
                      height: CARD_HEIGHT,
                      borderRadius: 24,
                      overflow: 'hidden',
                      shadowColor: '#000',
                      shadowOffset: { width: 0, height: 8 },
                      shadowOpacity: 0.15,
                      shadowRadius: 24,
                    },
                  ]}
                >
                  <Image
                    source={{ uri: currentPhoto.uri }}
                    style={{ width: '100%', height: '100%' }}
                    resizeMode="cover"
                  />

                  {/* Delete indicator overlay */}
                  <Animated.View
                    style={[
                      leftIndicatorStyle,
                      {
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        backgroundColor: 'rgba(239, 68, 68, 0.4)',
                        justifyContent: 'center',
                        alignItems: 'center',
                      },
                    ]}
                  >
                    <View className="w-20 h-20 rounded-full bg-red-500 items-center justify-center">
                      <Ionicons name="close" size={40} color="#fff" />
                    </View>
                    <Text className="text-white text-xl font-bold mt-3">
                      DELETE
                    </Text>
                  </Animated.View>

                  {/* Keep indicator overlay */}
                  <Animated.View
                    style={[
                      rightIndicatorStyle,
                      {
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        backgroundColor: 'rgba(34, 197, 94, 0.4)',
                        justifyContent: 'center',
                        alignItems: 'center',
                      },
                    ]}
                  >
                    <View className="w-20 h-20 rounded-full bg-green-500 items-center justify-center">
                      <Ionicons name="checkmark" size={40} color="#fff" />
                    </View>
                    <Text className="text-white text-xl font-bold mt-3">
                      KEEP
                    </Text>
                  </Animated.View>
                </Animated.View>
              </GestureDetector>
            )}
          </>
        )}
      </View>

      {/* Action Buttons */}
      {!isFinished && (
        <View
          className="flex-row items-center justify-center gap-8 pb-4"
          style={{ paddingBottom: insets.bottom + 16 }}
        >
          {/* Delete button */}
          <Pressable
            onPress={handleManualDelete}
            className="w-16 h-16 rounded-full bg-red-500 items-center justify-center active:scale-95"
            style={{
              shadowColor: '#ef4444',
              shadowOffset: { width: 0, height: 4 },
              shadowOpacity: 0.3,
              shadowRadius: 12,
            }}
          >
            <Ionicons name="close" size={32} color="#fff" />
          </Pressable>

          {/* Keep button */}
          <Pressable
            onPress={handleManualKeep}
            className="w-16 h-16 rounded-full bg-green-500 items-center justify-center active:scale-95"
            style={{
              shadowColor: '#22c55e',
              shadowOffset: { width: 0, height: 4 },
              shadowOpacity: 0.3,
              shadowRadius: 12,
            }}
          >
            <Ionicons name="checkmark" size={32} color="#fff" />
          </Pressable>
        </View>
      )}
    </View>
  );
}
