import React, { useCallback } from 'react';
import { Pressable, PressableProps, ViewStyle, StyleProp } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

const AnimatedPressableBase = Animated.createAnimatedComponent(Pressable);

interface AnimatedPressableProps extends Omit<PressableProps, 'style'> {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  scaleValue?: number;
  hapticFeedback?: 'light' | 'medium' | 'heavy' | 'none';
  animationType?: 'spring' | 'timing';
  className?: string;
}

export function AnimatedPressable({
  children,
  style,
  scaleValue = 0.97,
  hapticFeedback = 'light',
  animationType = 'spring',
  onPressIn,
  onPressOut,
  onPress,
  className,
  ...props
}: AnimatedPressableProps) {
  const scale = useSharedValue(1);
  const opacity = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      transform: [{ scale: scale.value }],
      opacity: opacity.value,
    };
  });

  const handlePressIn = useCallback(
    (e: any) => {
      if (animationType === 'spring') {
        scale.value = withSpring(scaleValue, {
          damping: 15,
          stiffness: 400,
        });
      } else {
        scale.value = withTiming(scaleValue, { duration: 100 });
      }
      opacity.value = withTiming(0.9, { duration: 100 });
      onPressIn?.(e);
    },
    [scaleValue, animationType, onPressIn]
  );

  const handlePressOut = useCallback(
    (e: any) => {
      if (animationType === 'spring') {
        scale.value = withSpring(1, {
          damping: 15,
          stiffness: 400,
        });
      } else {
        scale.value = withTiming(1, { duration: 150 });
      }
      opacity.value = withTiming(1, { duration: 150 });
      onPressOut?.(e);
    },
    [animationType, onPressOut]
  );

  const handlePress = useCallback(
    (e: any) => {
      if (hapticFeedback !== 'none') {
        const feedbackStyle =
          hapticFeedback === 'light'
            ? Haptics.ImpactFeedbackStyle.Light
            : hapticFeedback === 'medium'
              ? Haptics.ImpactFeedbackStyle.Medium
              : Haptics.ImpactFeedbackStyle.Heavy;
        Haptics.impactAsync(feedbackStyle);
      }
      onPress?.(e);
    },
    [hapticFeedback, onPress]
  );

  return (
    <AnimatedPressableBase
      style={[animatedStyle, style]}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      onPress={handlePress}
      className={className}
      {...props}
    >
      {children}
    </AnimatedPressableBase>
  );
}

// Higher-order component for easy wrapping
export function withPressAnimation<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  animationConfig?: Partial<AnimatedPressableProps>
) {
  return function AnimatedWrapper(props: P & { onPress?: () => void }) {
    return (
      <AnimatedPressable onPress={props.onPress} {...animationConfig}>
        <WrappedComponent {...props} />
      </AnimatedPressable>
    );
  };
}
