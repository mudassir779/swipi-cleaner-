import React from 'react';
import { View, ViewStyle, StyleProp, Platform } from 'react-native';
import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';

interface GlassmorphicCardProps {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  className?: string;
  intensity?: number;
  borderRadius?: number;
  showBorder?: boolean;
  showGlow?: boolean;
  glowColor?: string;
  tint?: 'light' | 'dark' | 'default';
}

export function GlassmorphicCard({
  children,
  style,
  className,
  intensity = 50,
  borderRadius = 16,
  showBorder = true,
  showGlow = false,
  glowColor = '#3b82f6',
  tint,
}: GlassmorphicCardProps) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const effectiveTint = tint || (isDark ? 'dark' : 'light');

  const containerStyle: ViewStyle = {
    borderRadius,
    overflow: 'hidden',
    ...(showGlow && {
      shadowColor: glowColor,
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.3,
      shadowRadius: 12,
      elevation: 8,
    }),
  };

  const borderStyle: ViewStyle = showBorder
    ? {
        borderWidth: 1,
        borderColor: isDark ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.05)',
      }
    : {};

  // Fallback for web or when BlurView doesn't work well
  if (Platform.OS === 'web') {
    return (
      <View
        style={[
          containerStyle,
          borderStyle,
          {
            backgroundColor: isDark
              ? 'rgba(30, 41, 59, 0.8)'
              : 'rgba(255, 255, 255, 0.8)',
            backdropFilter: `blur(${intensity}px)`,
          },
          style,
        ]}
        className={className}
      >
        {children}
      </View>
    );
  }

  return (
    <View style={[containerStyle, style]} className={className}>
      <BlurView
        intensity={intensity}
        tint={effectiveTint}
        style={[
          {
            flex: 1,
            borderRadius,
            overflow: 'hidden',
          },
          borderStyle,
        ]}
      >
        {/* Subtle gradient overlay for depth */}
        <LinearGradient
          colors={
            isDark
              ? ['rgba(255, 255, 255, 0.05)', 'rgba(255, 255, 255, 0)']
              : ['rgba(255, 255, 255, 0.8)', 'rgba(255, 255, 255, 0.4)']
          }
          start={{ x: 0, y: 0 }}
          end={{ x: 0, y: 1 }}
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
          }}
        />
        {children}
      </BlurView>
    </View>
  );
}

// Variant with animated entrance
export function AnimatedGlassmorphicCard({
  children,
  delay = 0,
  ...props
}: GlassmorphicCardProps & { delay?: number }) {
  const Animated = require('react-native-reanimated').default;
  const { FadeInDown } = require('react-native-reanimated');

  return (
    <Animated.View entering={FadeInDown.delay(delay).springify()}>
      <GlassmorphicCard {...props}>{children}</GlassmorphicCard>
    </Animated.View>
  );
}
