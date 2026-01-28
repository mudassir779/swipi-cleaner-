import React, { useState, useEffect } from 'react';
import { View, TextInput, Pressable } from 'react-native';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
} from 'react-native-reanimated';

interface SearchBarProps {
  value: string;
  onChangeText: (text: string) => void;
  onClear: () => void;
  placeholder?: string;
}

export function SearchBar({
  value,
  onChangeText,
  onClear,
  placeholder = 'Search photos...',
}: SearchBarProps) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [isFocused, setIsFocused] = useState(false);

  const scale = useSharedValue(1);

  useEffect(() => {
    scale.value = isFocused ? withSpring(1.02) : withSpring(1);
  }, [isFocused]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Animated.View style={animatedStyle} className="px-4 py-2">
      <View
        className={cn(
          'flex-row items-center px-4 py-3 rounded-xl',
          isFocused
            ? isDark
              ? 'bg-white/10 border border-blue-500/50'
              : 'bg-white border border-blue-500/50'
            : isDark
            ? 'bg-white/5'
            : 'bg-black/5'
        )}
      >
        <Ionicons
          name="search"
          size={18}
          color={isDark ? '#94a3b8' : '#64748b'}
        />
        <TextInput
          value={value}
          onChangeText={onChangeText}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          placeholder={placeholder}
          placeholderTextColor={isDark ? '#64748b' : '#94a3b8'}
          className={cn(
            'flex-1 ml-3 text-base',
            isDark ? 'text-white' : 'text-slate-900'
          )}
          autoCapitalize="none"
          autoCorrect={false}
        />
        {value.length > 0 && (
          <Pressable
            onPress={onClear}
            className={cn(
              'w-6 h-6 rounded-full items-center justify-center ml-2',
              isDark ? 'bg-white/10' : 'bg-black/5'
            )}
          >
            <Ionicons name="close" size={14} color={isDark ? '#94a3b8' : '#64748b'} />
          </Pressable>
        )}
      </View>
    </Animated.View>
  );
}
