import React, { useEffect, useState } from 'react';
import { View, Text, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { formatBytes, useGalleryStore } from '@/lib/state/gallery-store';
import * as Haptics from 'expo-haptics';
import { toast } from 'burnt';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withDelay,
  withTiming,
  withSequence,
  Easing,
} from 'react-native-reanimated';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { cn } from '@/lib/cn';
import { LinearGradient } from 'expo-linear-gradient';

export default function SuccessScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const lastDeletedPhotos = useGalleryStore((s) => s.lastDeletedPhotos);
  const clearLastDeletedPhotos = useGalleryStore((s) => s.clearLastDeletedPhotos);
  const removeFromRecentlyDeleted = useGalleryStore((s) => s.removeFromRecentlyDeleted);
  const [showUndoToast, setShowUndoToast] = useState(true);

  // Calculate storage saved from last deleted photos
  const storageSaved = lastDeletedPhotos.reduce((total, photo) => {
    return total + ((photo.asset as any)?.fileSize || 2 * 1024 * 1024);
  }, 0);

  // Animation values
  const checkScale = useSharedValue(0);
  const checkOpacity = useSharedValue(0);
  const ringScale = useSharedValue(0.5);
  const ringOpacity = useSharedValue(0);
  const contentOpacity = useSharedValue(0);
  const contentTranslateY = useSharedValue(30);
  const buttonOpacity = useSharedValue(0);
  const buttonTranslateY = useSharedValue(30);

  useEffect(() => {
    // Celebration animation sequence
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

    // Show undo toast if there are deleted photos
    if (lastDeletedPhotos.length > 0 && showUndoToast) {
      const timer = setTimeout(() => {
        toast({
          title: `${lastDeletedPhotos.length} photo${lastDeletedPhotos.length > 1 ? 's' : ''} deleted`,
          duration: 5000,
        });
        setShowUndoToast(false);
      }, 500);

      return () => clearTimeout(timer);
    }
  }, [lastDeletedPhotos, showUndoToast]);

  useEffect(() => {
    // Ring animation
    ringOpacity.value = withTiming(1, { duration: 300 });
    ringScale.value = withSequence(
      withTiming(1.2, { duration: 400, easing: Easing.out(Easing.cubic) }),
      withTiming(1, { duration: 200 })
    );

    // Check animation
    checkOpacity.value = withDelay(200, withTiming(1, { duration: 300 }));
    checkScale.value = withDelay(
      200,
      withSequence(
        withSpring(1.2, { damping: 8 }),
        withSpring(1, { damping: 12 })
      )
    );

    // Content animation
    contentOpacity.value = withDelay(500, withTiming(1, { duration: 400 }));
    contentTranslateY.value = withDelay(500, withSpring(0, { damping: 15 }));

    // Button animation
    buttonOpacity.value = withDelay(800, withTiming(1, { duration: 400 }));
    buttonTranslateY.value = withDelay(800, withSpring(0, { damping: 12 }));
  }, []);

  const ringAnimatedStyle = useAnimatedStyle(() => ({
    opacity: ringOpacity.value,
    transform: [{ scale: ringScale.value }],
  }));

  const checkAnimatedStyle = useAnimatedStyle(() => ({
    opacity: checkOpacity.value,
    transform: [{ scale: checkScale.value }],
  }));

  const contentAnimatedStyle = useAnimatedStyle(() => ({
    opacity: contentOpacity.value,
    transform: [{ translateY: contentTranslateY.value }],
  }));

  const buttonAnimatedStyle = useAnimatedStyle(() => ({
    opacity: buttonOpacity.value,
    transform: [{ translateY: buttonTranslateY.value }],
  }));

  const handleUndo = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    // Remove from recently deleted
    lastDeletedPhotos.forEach((photo) => {
      removeFromRecentlyDeleted(photo.id);
    });
    clearLastDeletedPhotos();
    toast({
      title: 'Photos restored to recently deleted',
      duration: 2000,
    });
    // Navigate back after a short delay
    setTimeout(() => {
      router.replace('/(tabs)');
    }, 500);
  };

  const handleBackToLibrary = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    clearLastDeletedPhotos();
    router.replace('/(tabs)');
  };

  const handleDone = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    clearLastDeletedPhotos();
    router.replace('/(tabs)');
  };

  return (
    <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-slate-50')}>
      <LinearGradient
        colors={isDark
          ? ['#0a0a0a', '#0f172a', '#1e1b4b']
          : ['#f8fafc', '#e0f2fe', '#dbeafe']
        }
        style={{ flex: 1, position: 'absolute', width: '100%', height: '100%' }}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />

      <View
        className="flex-1 items-center justify-center px-8"
        style={{ paddingTop: insets.top, paddingBottom: insets.bottom + 20 }}
      >
        {/* Success Icon */}
        <View className="relative items-center justify-center mb-10">
          {/* Outer ring */}
          <Animated.View
            style={[
              ringAnimatedStyle,
              {
                position: 'absolute',
                width: 140,
                height: 140,
                borderRadius: 70,
                borderWidth: 3,
                borderColor: isDark ? 'rgba(34, 197, 94, 0.3)' : 'rgba(34, 197, 94, 0.2)',
              },
            ]}
          />

          {/* Check icon container */}
          <Animated.View
            style={checkAnimatedStyle}
            className="w-28 h-28 rounded-full items-center justify-center"
          >
            <LinearGradient
              colors={['#22c55e', '#16a34a']}
              style={{
                width: 112,
                height: 112,
                borderRadius: 56,
                alignItems: 'center',
                justifyContent: 'center',
                shadowColor: '#22c55e',
                shadowOffset: { width: 0, height: 8 },
                shadowOpacity: 0.4,
                shadowRadius: 20,
              }}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
            >
              <Ionicons name="checkmark-circle" size={56} color="#fff" />
            </LinearGradient>
          </Animated.View>
        </View>

        {/* Content */}
        <Animated.View style={contentAnimatedStyle} className="items-center">
          <Text
            className={cn(
              'text-3xl font-bold text-center mb-3',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            Cleanup Complete
          </Text>

          <View
            className={cn(
              'flex-row items-center px-5 py-3 rounded-2xl mt-2',
              isDark ? 'bg-white/10' : 'bg-white'
            )}
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: isDark ? 0 : 0.05,
              shadowRadius: 8,
            }}
          >
            <MaterialIcons
              name="auto-awesome"
              size={20}
              color={isDark ? '#22c55e' : '#16a34a'}
            />
            <Text
              className={cn(
                'text-lg font-semibold ml-2',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              {formatBytes(storageSaved)} freed
            </Text>
          </View>

          <Text
            className={cn(
              'text-base text-center mt-4',
              isDark ? 'text-slate-400' : 'text-slate-500'
            )}
          >
            Your photos have been permanently removed
          </Text>
        </Animated.View>

        {/* Spacer */}
        <View className="flex-1" />

        {/* Buttons */}
        <Animated.View style={buttonAnimatedStyle} className="w-full">
          <Pressable
            onPress={handleBackToLibrary}
            className="active:scale-[0.98] active:opacity-90 mb-3"
          >
            <LinearGradient
              colors={isDark
                ? ['#3b82f6', '#2563eb']
                : ['#3b82f6', '#1d4ed8']
              }
              style={{
                paddingVertical: 18,
                borderRadius: 16,
                alignItems: 'center',
                flexDirection: 'row',
                justifyContent: 'center',
              }}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
            >
              <Text className="text-white text-lg font-semibold mr-2">
                Back to Library
              </Text>
              <Ionicons name="arrow-forward" size={20} color="#fff" />
            </LinearGradient>
          </Pressable>

          <Pressable
            onPress={handleDone}
            className={cn(
              'py-4 rounded-2xl items-center',
              isDark ? 'bg-white/10' : 'bg-black/5'
            )}
          >
            <Text
              className={cn(
                'text-base font-medium',
                isDark ? 'text-white' : 'text-slate-700'
              )}
            >
              Done
            </Text>
          </Pressable>
        </Animated.View>
      </View>
    </View>
  );
}
