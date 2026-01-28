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
  withSequence,
  withRepeat,
} from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons, Feather } from '@expo/vector-icons';
import { useColorScheme } from '@/lib/useColorScheme';
import * as Haptics from 'expo-haptics';

const { width } = Dimensions.get('window');

interface StepItemProps {
  icon: React.ReactNode;
  label: string;
  delay: number;
  isDark: boolean;
}

function StepItem({ icon, label, delay, isDark }: StepItemProps) {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(20);

  useEffect(() => {
    opacity.value = withDelay(delay, withTiming(1, { duration: 400 }));
    translateY.value = withDelay(delay, withSpring(0, { damping: 15 }));
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  return (
    <Animated.View
      style={animatedStyle}
      className={`flex-row items-center px-5 py-4 rounded-2xl mb-3 ${
        isDark ? 'bg-white/5' : 'bg-black/[0.03]'
      }`}
    >
      <View
        className={`w-12 h-12 rounded-xl items-center justify-center mr-4 ${
          isDark ? 'bg-blue-500/20' : 'bg-blue-500/10'
        }`}
      >
        {icon}
      </View>
      <Text
        className={`text-base flex-1 ${
          isDark ? 'text-white' : 'text-slate-800'
        }`}
      >
        {label}
      </Text>
    </Animated.View>
  );
}

export default function PermissionEducationScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  // Animation values
  const headerOpacity = useSharedValue(0);
  const headerTranslateY = useSharedValue(-20);
  const buttonOpacity = useSharedValue(0);
  const buttonTranslateY = useSharedValue(30);
  const shieldPulse = useSharedValue(1);

  useEffect(() => {
    headerOpacity.value = withTiming(1, { duration: 500 });
    headerTranslateY.value = withSpring(0, { damping: 15 });

    buttonOpacity.value = withDelay(1200, withTiming(1, { duration: 400 }));
    buttonTranslateY.value = withDelay(1200, withSpring(0, { damping: 12 }));

    // Subtle pulse animation for shield
    shieldPulse.value = withRepeat(
      withSequence(
        withTiming(1.05, { duration: 1500 }),
        withTiming(1, { duration: 1500 })
      ),
      -1,
      true
    );
  }, []);

  const headerAnimatedStyle = useAnimatedStyle(() => ({
    opacity: headerOpacity.value,
    transform: [{ translateY: headerTranslateY.value }],
  }));

  const buttonAnimatedStyle = useAnimatedStyle(() => ({
    opacity: buttonOpacity.value,
    transform: [{ translateY: buttonTranslateY.value }],
  }));

  const shieldAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: shieldPulse.value }],
  }));

  const handleContinue = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.push('/onboarding/photo-access');
  };

  const iconColor = isDark ? '#60a5fa' : '#3b82f6';

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
        className="flex-1 px-6"
        style={{ paddingTop: insets.top + 60, paddingBottom: insets.bottom + 20 }}
      >
        {/* Header */}
        <Animated.View style={headerAnimatedStyle} className="items-center mb-10">
          <Animated.View style={shieldAnimatedStyle}>
            <View
              className={`w-20 h-20 rounded-full items-center justify-center mb-6 ${
                isDark ? 'bg-green-500/20' : 'bg-green-500/10'
              }`}
            >
              <Ionicons name="shield" size={40} color={isDark ? '#4ade80' : '#22c55e'} />
            </View>
          </Animated.View>

          <Text
            className={`text-3xl font-bold text-center mb-3 ${
              isDark ? 'text-white' : 'text-slate-900'
            }`}
          >
            You're in control
          </Text>
          <Text
            className={`text-base text-center leading-6 ${
              isDark ? 'text-slate-400' : 'text-slate-500'
            }`}
          >
            Nothing is removed without your confirmation
          </Text>
        </Animated.View>

        {/* How it works */}
        <View className="flex-1">
          <Animated.Text
            style={headerAnimatedStyle}
            className={`text-sm font-medium uppercase tracking-wider mb-4 ${
              isDark ? 'text-slate-500' : 'text-slate-400'
            }`}
          >
            How it works
          </Animated.Text>

          <StepItem
            icon={<Ionicons name="images" size={24} color={iconColor} />}
            label="Browse your photos in a familiar grid"
            delay={400}
            isDark={isDark}
          />

          <StepItem
            icon={<Ionicons name="checkmark-circle" size={24} color={iconColor} />}
            label="Select photos you want to remove"
            delay={600}
            isDark={isDark}
          />

          <StepItem
            icon={<Feather name="trash-2" size={24} color={iconColor} />}
            label="Review your queue before deleting"
            delay={800}
            isDark={isDark}
          />

          <StepItem
            icon={<Ionicons name="shield" size={24} color={isDark ? '#4ade80' : '#22c55e'} />}
            label="Confirm to permanently remove"
            delay={1000}
            isDark={isDark}
          />
        </View>

        {/* Continue Button */}
        <Animated.View style={buttonAnimatedStyle}>
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
                flexDirection: 'row',
                justifyContent: 'center',
              }}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
            >
              <Text className="text-white text-lg font-semibold mr-2">
                Continue
              </Text>
              <Ionicons name="arrow-forward" size={20} color="#fff" />
            </LinearGradient>
          </Pressable>
        </Animated.View>
      </View>
    </View>
  );
}
