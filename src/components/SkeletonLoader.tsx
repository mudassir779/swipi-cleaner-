import React, { useEffect } from 'react';
import { View, Dimensions } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withRepeat,
  withTiming,
  interpolate,
} from 'react-native-reanimated';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';

const { width } = Dimensions.get('window');
const NUM_COLUMNS = 3;
const SPACING = 4;
const ITEM_SIZE = (width - SPACING * (NUM_COLUMNS + 1) - 32) / NUM_COLUMNS;

export function SkeletonLoader() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const shimmer = useSharedValue(0);

  useEffect(() => {
    shimmer.value = withRepeat(
      withTiming(1, { duration: 1500 }),
      -1,
      false
    );
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: interpolate(shimmer.value, [0, 0.5, 1], [0.3, 0.6, 0.3]),
  }));

  return (
    <View className="flex-row flex-wrap px-4 pt-2">
      {Array.from({ length: 12 }).map((_, index) => (
        <Animated.View
          key={index}
          style={[
            animatedStyle,
            {
              width: ITEM_SIZE,
              height: ITEM_SIZE,
              margin: SPACING / 2,
              borderRadius: 16,
              backgroundColor: isDark ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.1)',
            },
          ]}
        />
      ))}
    </View>
  );
}
