import React, { useEffect } from 'react';
import { View, Text, Pressable, Dimensions } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSpring,
  Easing,
  interpolate,
} from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { MaterialIcons } from '@expo/vector-icons';
import { useColorScheme } from '@/lib/useColorScheme';
import * as Haptics from 'expo-haptics';

const { width, height } = Dimensions.get('window');

export default function SplashScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  // Animation values
  const logoScale = useSharedValue(0.8);
  const logoOpacity = useSharedValue(0);
  const titleOpacity = useSharedValue(0);
  const titleTranslateY = useSharedValue(20);
  const taglineOpacity = useSharedValue(0);
  const buttonOpacity = useSharedValue(0);
  const buttonTranslateY = useSharedValue(30);

  useEffect(() => {
    // Staggered entrance animations
    logoOpacity.value = withDelay(200, withTiming(1, { duration: 600 }));
    logoScale.value = withDelay(200, withSpring(1, { damping: 12 }));

    titleOpacity.value = withDelay(500, withTiming(1, { duration: 500 }));
    titleTranslateY.value = withDelay(500, withSpring(0, { damping: 15 }));

    taglineOpacity.value = withDelay(700, withTiming(1, { duration: 500 }));

    buttonOpacity.value = withDelay(1000, withTiming(1, { duration: 400 }));
    buttonTranslateY.value = withDelay(1000, withSpring(0, { damping: 12 }));
  }, []);

  const logoAnimatedStyle = useAnimatedStyle(() => ({
    opacity: logoOpacity.value,
    transform: [{ scale: logoScale.value }],
  }));

  const titleAnimatedStyle = useAnimatedStyle(() => ({
    opacity: titleOpacity.value,
    transform: [{ translateY: titleTranslateY.value }],
  }));

  const taglineAnimatedStyle = useAnimatedStyle(() => ({
    opacity: taglineOpacity.value,
  }));

  const buttonAnimatedStyle = useAnimatedStyle(() => ({
    opacity: buttonOpacity.value,
    transform: [{ translateY: buttonTranslateY.value }],
  }));

  const handleContinue = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.push('/onboarding/permission-education');
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
        className="flex-1 justify-center items-center px-8"
        style={{ paddingTop: insets.top, paddingBottom: insets.bottom }}
      >
        {/* Logo */}
        <Animated.View style={logoAnimatedStyle} className="mb-8">
          <View
            className={`w-28 h-28 rounded-[32px] items-center justify-center ${
              isDark ? 'bg-white/10' : 'bg-black/5'
            }`}
            style={{
              shadowColor: isDark ? '#3b82f6' : '#000',
              shadowOffset: { width: 0, height: 8 },
              shadowOpacity: isDark ? 0.3 : 0.1,
              shadowRadius: 24,
            }}
          >
            <MaterialIcons
              name="auto-awesome"
              size={48}
              color={isDark ? '#60a5fa' : '#3b82f6'}
            />
          </View>
        </Animated.View>

        {/* Title */}
        <Animated.View style={titleAnimatedStyle}>
          <Text
            className={`text-4xl font-bold text-center tracking-tight ${
              isDark ? 'text-white' : 'text-slate-900'
            }`}
          >
            Clean Gallery
          </Text>
        </Animated.View>

        {/* Tagline */}
        <Animated.View style={taglineAnimatedStyle} className="mt-4">
          <Text
            className={`text-lg text-center ${
              isDark ? 'text-slate-400' : 'text-slate-500'
            }`}
          >
            Review and clean your photo gallery
          </Text>
        </Animated.View>

        {/* Spacer */}
        <View className="flex-1" />

        {/* Continue Button */}
        <Animated.View style={buttonAnimatedStyle} className="w-full mb-4">
          <Pressable
            onPress={handleContinue}
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
              }}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
            >
              <Text className="text-white text-lg font-semibold">
                Get Started
              </Text>
            </LinearGradient>
          </Pressable>
        </Animated.View>
      </View>
    </View>
  );
}
