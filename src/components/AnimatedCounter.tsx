import React, { useEffect, useState } from "react";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  interpolate,
  Extrapolation,
  runOnJS,
} from "react-native-reanimated";
import { Text } from "react-native";
import { useColorScheme } from "@/lib/useColorScheme";
import { cn } from "@/lib/cn";

interface AnimatedCounterProps {
  value: number;
  className?: string;
  duration?: number;
}

export function AnimatedCounter({
  value,
  className,
  duration = 800,
}: AnimatedCounterProps) {
  const [displayValue, setDisplayValue] = useState(0);
  const animatedValue = useSharedValue(0);

  useEffect(() => {
    animatedValue.value = withTiming(value, { duration }, (finished) => {
      if (finished) {
        runOnJS(setDisplayValue)(value);
      }
    });

    // Update display value during animation
    const interval = setInterval(() => {
      setDisplayValue(Math.round(animatedValue.value));
    }, 16);

    return () => clearInterval(interval);
  }, [value, duration]);

  const animatedStyle = useAnimatedStyle(() => {
    const opacity = interpolate(
      animatedValue.value,
      [0, value || 1],
      [0, 1],
      Extrapolation.CLAMP,
    );
    const scale = interpolate(
      animatedValue.value,
      [0, value || 1],
      [0.8, 1],
      Extrapolation.CLAMP,
    );
    return {
      opacity,
      transform: [{ scale }],
    };
  });

  return (
    <Animated.Text
      style={animatedStyle}
      className={cn("text-2xl font-bold", className)}
    >
      {displayValue.toLocaleString()}
    </Animated.Text>
  );
}
