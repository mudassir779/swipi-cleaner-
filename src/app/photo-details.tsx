import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  Dimensions,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore, formatBytes } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  runOnJS,
  interpolate,
  Extrapolation,
  FadeIn,
  FadeOut,
  FadeInDown,
  SlideInDown,
  SlideOutDown,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import { Image } from 'expo-image';
import { Ionicons, Feather } from '@expo/vector-icons';
import { cn } from '@/lib/cn';
import { AnimatedPressable } from '@/components/AnimatedPressable';
import { format } from 'date-fns';
import * as Sharing from 'expo-sharing';
import { BlurView } from 'expo-blur';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

interface ActionButtonProps {
  icon: React.ReactNode;
  onPress: () => void;
  size?: 'normal' | 'large';
  isActive?: boolean;
  activeColor?: string;
  isDark: boolean;
  delay?: number;
}

function ActionButton({
  icon,
  onPress,
  size = 'normal',
  isActive = false,
  activeColor = '#ef4444',
  isDark,
  delay = 0,
}: ActionButtonProps) {
  const buttonSize = size === 'large' ? 'w-16 h-16' : 'w-14 h-14';
  
  return (
    <Animated.View entering={FadeInDown.delay(delay).springify()}>
      <AnimatedPressable
        onPress={onPress}
        scaleValue={0.9}
        className={cn(
          buttonSize,
          'rounded-full items-center justify-center',
          isActive ? '' : isDark ? 'bg-white/10' : 'bg-black/5',
        )}
        style={isActive ? { backgroundColor: activeColor } : undefined}
      >
        {icon}
      </AnimatedPressable>
    </Animated.View>
  );
}

export default function PhotoDetailsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const params = useLocalSearchParams<{ id: string; photoIds?: string }>();

  const [photo, setPhoto] = useState<MediaLibrary.Asset | null>(null);
  const [photoInfo, setPhotoInfo] = useState<MediaLibrary.AssetInfo | null>(null);
  const [allPhotoIds, setAllPhotoIds] = useState<string[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [showMetadata, setShowMetadata] = useState(false);

  const addToDeleteQueue = useGalleryStore((s) => s.addToDeleteQueue);
  const removeFromDeleteQueue = useGalleryStore((s) => s.removeFromDeleteQueue);
  const isInDeleteQueue = useGalleryStore((s) => s.isInDeleteQueue);


  // Zoom and pan gestures
  const scale = useSharedValue(1);
  const savedScale = useSharedValue(1);
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const savedTranslateX = useSharedValue(0);
  const savedTranslateY = useSharedValue(0);

  // Swipe between photos
  const swipeX = useSharedValue(0);
  const opacity = useSharedValue(1);

  const loadPhoto = useCallback(async () => {
    try {
      setLoading(true);
      const asset = await MediaLibrary.getAssetInfoAsync(params.id);
      if (asset) {
        setPhoto(asset);
        setPhotoInfo(asset);

        // Load all photo IDs if provided
        if (params.photoIds) {
          const ids = params.photoIds.split(',');
          setAllPhotoIds(ids);
          const index = ids.indexOf(params.id);
          if (index !== -1) {
            setCurrentIndex(index);
          }
        } else {
          // Load all photos to enable navigation
          const result = await MediaLibrary.getAssetsAsync({
            first: 1000,
            mediaType: 'photo',
            sortBy: [[MediaLibrary.SortBy.creationTime, false]],
          });
          const ids = result.assets.map((a) => a.id);
          setAllPhotoIds(ids);
          const index = ids.indexOf(params.id);
          if (index !== -1) {
            setCurrentIndex(index);
          }
        }
      }
    } catch (error) {
      console.error('Error loading photo:', error);
    } finally {
      setLoading(false);
    }
  }, [params.id, params.photoIds]);

  useEffect(() => {
    loadPhoto();
  }, [loadPhoto]);

  const navigateToPhoto = useCallback(
    (direction: 'prev' | 'next') => {
      if (allPhotoIds.length === 0) return;

      const newIndex =
        direction === 'next'
          ? (currentIndex + 1) % allPhotoIds.length
          : (currentIndex - 1 + allPhotoIds.length) % allPhotoIds.length;

      const newId = allPhotoIds[newIndex];
      if (newId) {
        setCurrentIndex(newIndex);
        router.setParams({ id: newId });
        // Reset zoom and pan
        scale.value = withSpring(1);
        savedScale.value = 1;
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
        savedTranslateX.value = 0;
        savedTranslateY.value = 0;
      }
    },
    [allPhotoIds, currentIndex, router, scale, savedScale, translateX, translateY, savedTranslateX, savedTranslateY]
  );

  // Pinch gesture for zoom
  const pinchGesture = Gesture.Pinch()
    .onUpdate((event) => {
      scale.value = savedScale.value * event.scale;
    })
    .onEnd(() => {
      if (scale.value < 1) {
        scale.value = withSpring(1);
        savedScale.value = 1;
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
        savedTranslateX.value = 0;
        savedTranslateY.value = 0;
      } else if (scale.value > 3) {
        scale.value = withSpring(3);
        savedScale.value = 3;
      } else {
        savedScale.value = scale.value;
      }
    });

  // Pan gesture for moving zoomed image
  const panGesture = Gesture.Pan()
    .onUpdate((event) => {
      if (scale.value > 1) {
        translateX.value = savedTranslateX.value + event.translationX;
        translateY.value = savedTranslateY.value + event.translationY;
      }
    })
    .onEnd(() => {
      savedTranslateX.value = translateX.value;
      savedTranslateY.value = translateY.value;
    });

  // Swipe gesture for navigation
  const swipeGesture = Gesture.Pan()
    .enabled(scale.value === 1)
    .onUpdate((event) => {
      if (scale.value === 1) {
        swipeX.value = event.translationX;
        opacity.value = interpolate(
          Math.abs(event.translationX),
          [0, SCREEN_WIDTH / 2],
          [1, 0.5],
          Extrapolation.CLAMP
        );
      }
    })
    .onEnd((event) => {
      if (Math.abs(event.translationX) > SCREEN_WIDTH / 3 && scale.value === 1) {
        if (event.translationX > 0) {
          runOnJS(navigateToPhoto)('prev');
        } else {
          runOnJS(navigateToPhoto)('next');
        }
      }
      swipeX.value = withSpring(0);
      opacity.value = withSpring(1);
    });

  const composedGesture = Gesture.Simultaneous(
    Gesture.Race(swipeGesture, panGesture),
    pinchGesture
  );

  const imageAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value + swipeX.value },
      { translateY: translateY.value },
      { scale: scale.value },
    ],
    opacity: opacity.value,
  }));

  const handleClose = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.back();
  };

  const handleToggleDelete = () => {
    if (!photo) return;

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    if (isInDeleteQueue(photo.id)) {
      removeFromDeleteQueue(photo.id);
    } else {
      addToDeleteQueue(photo.id);
    }
  };

  const handleShare = async () => {
    if (!photo) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    
    try {
      const isAvailable = await Sharing.isAvailableAsync();
      if (!isAvailable) {
        // Fallback: copy to clipboard or show alert
        return;
      }
      
      await Sharing.shareAsync(photo.uri, {
        mimeType: 'image/jpeg',
        dialogTitle: 'Share Photo',
      });
    } catch (error) {
      console.error('Error sharing photo:', error);
    }
  };

  const handlePrevious = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    navigateToPhoto('prev');
  };

  const handleNext = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    navigateToPhoto('next');
  };

  const handleToggleMetadata = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setShowMetadata(!showMetadata);
  };

  const isQueued = photo ? isInDeleteQueue(photo.id) : false;

  if (loading || !photo) {
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
      <Animated.View
        entering={FadeIn.duration(300)}
        className={cn(
          'absolute top-0 left-0 right-0 z-10 flex-row items-center justify-between px-4',
        )}
        style={{ paddingTop: insets.top + 8, paddingBottom: 12 }}
      >
        <BlurView
          intensity={80}
          tint={isDark ? 'dark' : 'light'}
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
          }}
        />
        <AnimatedPressable
          onPress={handleClose}
          className={cn(
            'w-10 h-10 rounded-full items-center justify-center',
            isDark ? 'bg-white/10' : 'bg-black/5'
          )}
          scaleValue={0.9}
        >
          <Ionicons name="close" size={24} color={isDark ? '#fff' : '#1e293b'} />
        </AnimatedPressable>

        <View className="flex-row items-center gap-2">
          <Text
            className={cn(
              'text-sm font-medium',
              isDark ? 'text-slate-300' : 'text-slate-600'
            )}
          >
            {currentIndex + 1} of {allPhotoIds.length}
          </Text>
        </View>

        <AnimatedPressable
          onPress={handleToggleMetadata}
          className={cn(
            'w-10 h-10 rounded-full items-center justify-center',
            isDark ? 'bg-white/10' : 'bg-black/5',
            showMetadata && (isDark ? 'bg-blue-500/30' : 'bg-blue-500/20')
          )}
          scaleValue={0.9}
        >
          <Ionicons
            name="information-circle"
            size={22}
            color={showMetadata ? '#3b82f6' : isDark ? '#fff' : '#1e293b'}
          />
        </AnimatedPressable>
      </Animated.View>

      {/* Image Viewer */}
      <GestureDetector gesture={composedGesture}>
        <Animated.View
          style={[
            {
              flex: 1,
              justifyContent: 'center',
              alignItems: 'center',
            },
            imageAnimatedStyle,
          ]}
        >
          <Image
            source={{ uri: photo.uri }}
            style={{
              width: SCREEN_WIDTH,
              height: SCREEN_HEIGHT,
            }}
            contentFit="contain"
            transition={200}
          />
        </Animated.View>
      </GestureDetector>

      {/* Navigation Arrows */}
      {allPhotoIds.length > 1 && (
        <>
          <AnimatedPressable
            onPress={handlePrevious}
            className={cn(
              'absolute left-4 top-1/2 w-12 h-12 rounded-full items-center justify-center',
              isDark ? 'bg-white/10' : 'bg-black/10'
            )}
            style={{ marginTop: -24 }}
            scaleValue={0.9}
          >
            <Ionicons name="chevron-back" size={24} color={isDark ? '#fff' : '#1e293b'} />
          </AnimatedPressable>
          <AnimatedPressable
            onPress={handleNext}
            className={cn(
              'absolute right-4 top-1/2 w-12 h-12 rounded-full items-center justify-center',
              isDark ? 'bg-white/10' : 'bg-black/10'
            )}
            style={{ marginTop: -24 }}
            scaleValue={0.9}
          >
            <Ionicons name="chevron-forward" size={24} color={isDark ? '#fff' : '#1e293b'} />
          </AnimatedPressable>
        </>
      )}

      {/* Metadata Panel */}
      {showMetadata && photoInfo && (
        <Animated.View
          entering={SlideInDown.springify()}
          exiting={SlideOutDown.springify()}
          className={cn(
            'absolute bottom-0 left-0 right-0 max-h-[60%]',
          )}
          style={{ paddingBottom: insets.bottom + 100 }}
        >
          <BlurView
            intensity={90}
            tint={isDark ? 'dark' : 'light'}
            style={{
              flex: 1,
              borderTopLeftRadius: 24,
              borderTopRightRadius: 24,
              overflow: 'hidden',
            }}
          >
            <ScrollView
              className="flex-1 px-4 pt-4"
              showsVerticalScrollIndicator={false}
            >
              <View className="mb-4">
                <Text
                  className={cn(
                    'text-lg font-semibold mb-4',
                    isDark ? 'text-white' : 'text-slate-900'
                  )}
                >
                  Photo Information
                </Text>

                {/* Date */}
                <Animated.View 
                  entering={FadeInDown.delay(100).springify()}
                  className="flex-row items-center mb-3"
                >
                  <View className={cn(
                    'w-8 h-8 rounded-lg items-center justify-center mr-3',
                    isDark ? 'bg-white/10' : 'bg-black/5'
                  )}>
                    <Ionicons
                      name="calendar"
                      size={16}
                      color={isDark ? '#94a3b8' : '#64748b'}
                    />
                  </View>
                  <Text
                    className={cn('text-sm', isDark ? 'text-slate-300' : 'text-slate-600')}
                  >
                    {format(new Date(photo.creationTime), 'MMMM d, yyyy h:mm a')}
                  </Text>
                </Animated.View>

                {/* File Size */}
                {(photoInfo as any).fileSize && (
                  <Animated.View 
                    entering={FadeInDown.delay(150).springify()}
                    className="flex-row items-center mb-3"
                  >
                    <View className={cn(
                      'w-8 h-8 rounded-lg items-center justify-center mr-3',
                      isDark ? 'bg-white/10' : 'bg-black/5'
                    )}>
                      <Ionicons
                        name="document"
                        size={16}
                        color={isDark ? '#94a3b8' : '#64748b'}
                      />
                    </View>
                    <Text
                      className={cn('text-sm', isDark ? 'text-slate-300' : 'text-slate-600')}
                    >
                      {formatBytes((photoInfo as any).fileSize)}
                    </Text>
                  </Animated.View>
                )}

                {/* Dimensions */}
                <Animated.View 
                  entering={FadeInDown.delay(200).springify()}
                  className="flex-row items-center mb-3"
                >
                  <View className={cn(
                    'w-8 h-8 rounded-lg items-center justify-center mr-3',
                    isDark ? 'bg-white/10' : 'bg-black/5'
                  )}>
                    <Ionicons
                      name="resize-outline"
                      size={16}
                      color={isDark ? '#94a3b8' : '#64748b'}
                    />
                  </View>
                  <Text
                    className={cn('text-sm', isDark ? 'text-slate-300' : 'text-slate-600')}
                  >
                    {photo.width} × {photo.height}
                  </Text>
                </Animated.View>

                {/* Filename */}
                {photoInfo.filename && (
                  <Animated.View 
                    entering={FadeInDown.delay(250).springify()}
                    className="flex-row items-center mb-3"
                  >
                    <View className={cn(
                      'w-8 h-8 rounded-lg items-center justify-center mr-3',
                      isDark ? 'bg-white/10' : 'bg-black/5'
                    )}>
                      <Ionicons
                        name="document-text"
                        size={16}
                        color={isDark ? '#94a3b8' : '#64748b'}
                      />
                    </View>
                    <Text
                      className={cn(
                        'text-sm flex-1',
                        isDark ? 'text-slate-300' : 'text-slate-600'
                      )}
                      numberOfLines={1}
                    >
                      {photoInfo.filename}
                    </Text>
                  </Animated.View>
                )}
              </View>
            </ScrollView>
          </BlurView>
        </Animated.View>
      )}

      {/* Action Buttons */}
      <Animated.View
        entering={FadeIn.delay(200)}
        className={cn(
          'absolute bottom-0 left-0 right-0 flex-row items-center justify-center gap-6 px-4',
        )}
        style={{ paddingBottom: insets.bottom + 16, paddingTop: 16 }}
      >
        <BlurView
          intensity={80}
          tint={isDark ? 'dark' : 'light'}
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
          }}
        />
        <ActionButton
          icon={<Ionicons name="share" size={22} color={isDark ? '#fff' : '#1e293b'} />}
          onPress={handleShare}
          isDark={isDark}
          delay={100}
        />

        <ActionButton
          icon={
            <Feather
              name="trash-2"
              size={24}
              color={isQueued ? '#fff' : isDark ? '#fff' : '#1e293b'}
            />
          }
          onPress={handleToggleDelete}
          size="large"
          isActive={isQueued}
          isDark={isDark}
          delay={200}
        />
      </Animated.View>
    </View>
  );
}
