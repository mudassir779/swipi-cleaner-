import React, { useState } from 'react';
import { View, TextInput, Pressable } from 'react-native';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
  FadeIn,
  FadeOut,
} from 'react-native-reanimated';
import { BlurView } from 'expo-blur';

interface ModernSearchBarProps {
  value: string;
  onChangeText: (text: string) => void;
  onClear: () => void;
  placeholder?: string;
}

export function ModernSearchBar({
  value,
  onChangeText,
  onClear,
  placeholder = 'Search photos...',
}: ModernSearchBarProps) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [isFocused, setIsFocused] = useState(false);

  const scale = useSharedValue(1);
  const borderWidth = useSharedValue(0);
  const glow = useSharedValue(0);

  React.useEffect(() => {
    if (isFocused) {
      scale.value = withSpring(1.02, { damping: 15 });
      borderWidth.value = withTiming(2, { duration: 200 });
      glow.value = withTiming(1, { duration: 300 });
    } else {
      scale.value = withSpring(1, { damping: 15 });
      borderWidth.value = withTiming(0, { duration: 200 });
      glow.value = withTiming(0, { duration: 300 });
    }
  }, [isFocused]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    borderWidth: borderWidth.value,
    shadowOpacity: interpolate(glow.value, [0, 1], [0, 0.3]),
    shadowRadius: interpolate(glow.value, [0, 1], [0, 12]),
  }));

  return (
    <Animated.View style={animatedStyle} className="px-4 py-3">
      <BlurView
        intensity={isDark ? 20 : 30}
        tint={isDark ? 'dark' : 'light'}
        className="rounded-2xl overflow-hidden"
      >
        <View
          className={cn(
            'flex-row items-center px-4 py-3.5',
            isFocused
              ? isDark
                ? 'bg-white/10'
                : 'bg-white/80'
              : isDark
              ? 'bg-white/5'
              : 'bg-white/60'
          )}
          style={{
            borderColor: isFocused ? (isDark ? '#60a5fa' : '#3b82f6') : 'transparent',
          }}
        >
          <Animated.View
            style={useAnimatedStyle(() => ({
              opacity: interpolate(glow.value, [0, 1], [0.5, 1]),
            }))}
          >
            <Ionicons
              name="search"
              size={20}
              color={isFocused ? (isDark ? '#60a5fa' : '#3b82f6') : (isDark ? '#94a3b8' : '#64748b')}
            />
          </Animated.View>
          <TextInput
            value={value}
            onChangeText={onChangeText}
            onFocus={() => setIsFocused(true)}
            onBlur={() => setIsFocused(false)}
            placeholder={placeholder}
            placeholderTextColor={isDark ? '#64748b' : '#94a3b8'}
            className={cn(
              'flex-1 ml-3 text-base font-medium',
              isDark ? 'text-white' : 'text-slate-900'
            )}
            autoCapitalize="none"
            autoCorrect={false}
          />
          {value.length > 0 && (
            <Animated.View
              entering={FadeIn.duration(200)}
              exiting={FadeOut.duration(150)}
            >
              <Pressable
                onPress={onClear}
                className={cn(
                  'w-7 h-7 rounded-full items-center justify-center ml-2',
                  isDark ? 'bg-white/10' : 'bg-black/5'
                )}
              >
                <Ionicons name="close" size={16} color={isDark ? '#94a3b8' : '#64748b'} />
              </Pressable>
            </Animated.View>
          )}
        </View>
      </BlurView>
    </Animated.View>
  );
}
