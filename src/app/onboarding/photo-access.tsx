import React, { useEffect } from 'react';
import { View, Text, Pressable, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSpring,
} from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';

export default function PhotoAccessScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const setHasCompletedOnboarding = useGalleryStore((s) => s.setHasCompletedOnboarding);

  // Animation values
  const contentOpacity = useSharedValue(0);
  const contentTranslateY = useSharedValue(20);
  const buttonOpacity = useSharedValue(0);
  const buttonTranslateY = useSharedValue(30);

  useEffect(() => {
    contentOpacity.value = withTiming(1, { duration: 500 });
    contentTranslateY.value = withSpring(0, { damping: 15 });

    buttonOpacity.value = withDelay(400, withTiming(1, { duration: 400 }));
    buttonTranslateY.value = withDelay(400, withSpring(0, { damping: 12 }));
  }, []);

  const contentAnimatedStyle = useAnimatedStyle(() => ({
    opacity: contentOpacity.value,
    transform: [{ translateY: contentTranslateY.value }],
  }));

  const buttonAnimatedStyle = useAnimatedStyle(() => ({
    opacity: buttonOpacity.value,
    transform: [{ translateY: buttonTranslateY.value }],
  }));

  const requestPermission = async () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);

    const { status } = await MediaLibrary.requestPermissionsAsync();

    if (status === 'granted') {
      setHasCompletedOnboarding(true);
      router.replace('/(tabs)');
    } else {
      Alert.alert(
        'Permission Required',
        'Clean Gallery needs access to your photos to help you review and clean them. Please enable photo access in Settings.',
        [{ text: 'OK' }]
      );
    }
  };

  return (
    <View className="flex-1">
      <LinearGradient
        colors={isDark
          ? ['#0a0a0a', '#1a1a2e', '#16213e']
          : ['#f8fafc', '#e2e8f0', '#cbd5e1']
        }
        style={{ flex: 1, position: 'absolute', width: '100%', height: '100%' }}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />

      <View
        className="flex-1 px-6 justify-center"
        style={{ paddingTop: insets.top, paddingBottom: insets.bottom + 20 }}
      >
        <Animated.View style={contentAnimatedStyle} className="items-center">
          {/* Icon */}
          <View
            className={`w-32 h-32 rounded-[40px] items-center justify-center mb-8 ${
              isDark ? 'bg-blue-500/20' : 'bg-blue-500/10'
            }`}
            style={{
              shadowColor: isDark ? '#3b82f6' : '#000',
              shadowOffset: { width: 0, height: 12 },
              shadowOpacity: isDark ? 0.4 : 0.1,
              shadowRadius: 32,
            }}
          >
            <Ionicons
              name="image"
              size={56}
              color={isDark ? '#60a5fa' : '#3b82f6'}
              strokeWidth={1.5}
            />
          </View>

          {/* Title */}
          <Text
            className={`text-3xl font-bold text-center mb-4 ${
              isDark ? 'text-white' : 'text-slate-900'
            }`}
          >
            Allow Photo Access
          </Text>

          {/* Description */}
          <Text
            className={`text-base text-center leading-6 mb-2 ${
              isDark ? 'text-slate-400' : 'text-slate-500'
            }`}
          >
            We need access to your photos so you can review and select which ones to remove.
          </Text>

          {/* Privacy note */}
          <View
            className={`flex-row items-center mt-6 px-4 py-3 rounded-xl ${
              isDark ? 'bg-white/5' : 'bg-black/[0.03]'
            }`}
          >
            <Ionicons
              name="lock-closed"
              size={18}
              color={isDark ? '#94a3b8' : '#64748b'}
              strokeWidth={1.5}
            />
            <Text
              className={`text-sm ml-2 ${
                isDark ? 'text-slate-400' : 'text-slate-500'
              }`}
            >
              Your photos never leave your device
            </Text>
          </View>
        </Animated.View>

        {/* Spacer */}
        <View className="flex-1" />

        {/* Allow Access Button */}
        <Animated.View style={buttonAnimatedStyle}>
          <Pressable
            onPress={requestPermission}
            className="active:scale-[0.98] active:opacity-90"
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
                Allow Access
              </Text>
              <Ionicons name="arrow-forward" size={20} color="#fff" />
            </LinearGradient>
          </Pressable>
        </Animated.View>
      </View>
    </View>
  );
}
