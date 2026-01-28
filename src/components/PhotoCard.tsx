import React from 'react';
import { View, Pressable, Dimensions } from 'react-native';
import { Image } from 'expo-image';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
  Extrapolation,
  FadeIn,
} from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');
const NUM_COLUMNS = 3;
const SPACING = 4;
const ITEM_SIZE = (width - SPACING * (NUM_COLUMNS + 1) - 32) / NUM_COLUMNS;

interface PhotoCardProps {
  item: any;
  isSelected: boolean;
  isSelectionMode: boolean;
  onPress: () => void;
  onLongPress: () => void;
  index: number;
}

export function PhotoCard({
  item,
  isSelected,
  isSelectionMode,
  onPress,
  onLongPress,
  index,
}: PhotoCardProps) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const scale = useSharedValue(1);
  const opacity = useSharedValue(1);
  const shadowOpacity = useSharedValue(0.1);

  const handlePressIn = () => {
    scale.value = withSpring(0.95, { damping: 15 });
    shadowOpacity.value = withTiming(0.2, { duration: 100 });
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
    shadowOpacity.value = withTiming(0.1, { duration: 100 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
    shadowOpacity: shadowOpacity.value,
  }));

  const overlayStyle = useAnimatedStyle(() => ({
    opacity: interpolate(
      scale.value,
      [0.95, 1],
      [0.4, isSelected ? 0.3 : 0],
      Extrapolation.CLAMP
    ),
  }));

  return (
    <Animated.View
      style={[
        animatedStyle,
        {
          width: ITEM_SIZE,
          height: ITEM_SIZE,
          margin: SPACING / 2,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 4 },
          shadowRadius: 8,
        },
      ]}
    >
      <Pressable
        onPress={onPress}
        onLongPress={onLongPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        style={{ flex: 1 }}
      >
        <View className="flex-1 rounded-2xl overflow-hidden bg-slate-200 dark:bg-slate-800">
          <Image
            source={{ uri: item.uri }}
            style={{
              width: '100%',
              height: '100%',
            }}
            contentFit="cover"
            transition={200}
            cachePolicy="memory-disk"
          />

          {/* Gradient Overlay */}
          <Animated.View
            style={[
              overlayStyle,
              {
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0,
                height: '30%',
              },
            ]}
          >
            <LinearGradient
              colors={['transparent', 'rgba(0,0,0,0.6)']}
              style={{ flex: 1 }}
            />
          </Animated.View>

          {/* Selection Overlay */}
          {isSelectionMode && (
            <Animated.View
              entering={FadeIn.duration(200)}
              className={cn(
                'absolute inset-0 rounded-2xl',
                isSelected ? 'bg-red-500/40' : 'bg-transparent'
              )}
            />
          )}

          {/* Selection Indicator */}
          {isSelectionMode && (
            <Animated.View
              entering={FadeIn.duration(200)}
              className="absolute top-2 right-2"
            >
              {isSelected ? (
                <View className="w-7 h-7 rounded-full bg-red-500 items-center justify-center shadow-lg">
                  <Ionicons name="close" size={16} color="#fff" />
                </View>
              ) : (
                <View
                  className={cn(
                    'w-7 h-7 rounded-full border-2',
                    isDark ? 'border-white/80 bg-black/40' : 'border-white bg-black/30'
                  )}
                />
              )}
            </Animated.View>
          )}

          {/* Card Shadow Border */}
          <View
            className={cn(
              'absolute inset-0 rounded-2xl border',
              isDark ? 'border-white/5' : 'border-black/5'
            )}
            pointerEvents="none"
          />
        </View>
      </Pressable>
    </Animated.View>
  );
}

