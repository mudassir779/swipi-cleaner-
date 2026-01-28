import React, { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSequence,
  runOnJS,
  Easing,
} from 'react-native-reanimated';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '@/lib/theme';

const SPLASH_DURATION = 2000; // 2 seconds

export default function SplashScreen() {
  const router = useRouter();
  
  // Animation values
  const logoScale = useSharedValue(0.5);
  const logoOpacity = useSharedValue(0);
  const titleOpacity = useSharedValue(0);
  const subtitleOpacity = useSharedValue(0);
  const fadeOut = useSharedValue(1);

  useEffect(() => {
    // Logo animation - scale and fade in
    logoScale.value = withTiming(1, { duration: 600, easing: Easing.out(Easing.back(1.5)) });
    logoOpacity.value = withTiming(1, { duration: 400 });
    
    // Title fade in after logo
    titleOpacity.value = withDelay(300, withTiming(1, { duration: 400 }));
    
    // Subtitle fade in after title
    subtitleOpacity.value = withDelay(500, withTiming(1, { duration: 400 }));
    
    // Fade out and navigate
    fadeOut.value = withDelay(
      SPLASH_DURATION - 300,
      withTiming(0, { duration: 300 }, (finished) => {
        if (finished) {
          runOnJS(navigateToHome)();
        }
      })
    );
  }, []);

  const navigateToHome = () => {
    router.replace('/(tabs)/home');
  };

  const logoAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: logoScale.value }],
    opacity: logoOpacity.value,
  }));

  const titleAnimatedStyle = useAnimatedStyle(() => ({
    opacity: titleOpacity.value,
  }));

  const subtitleAnimatedStyle = useAnimatedStyle(() => ({
    opacity: subtitleOpacity.value,
  }));

  const containerAnimatedStyle = useAnimatedStyle(() => ({
    opacity: fadeOut.value,
  }));

  return (
    <Animated.View style={[styles.container, containerAnimatedStyle]}>
      {/* Logo */}
      <Animated.View style={[styles.logoContainer, logoAnimatedStyle]}>
        <View style={styles.logoCircle}>
          <Ionicons name="images" size={48} color={theme.colors.primary} />
        </View>
      </Animated.View>

      {/* Title */}
      <Animated.Text style={[styles.title, titleAnimatedStyle]}>
        Photo Cleanup
      </Animated.Text>

      {/* Subtitle */}
      <Animated.Text style={[styles.subtitle, subtitleAnimatedStyle]}>
        Declutter · Organize your memories
      </Animated.Text>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoContainer: {
    marginBottom: 24,
  },
  logoCircle: {
    width: 100,
    height: 100,
    borderRadius: 25,
    backgroundColor: theme.colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: theme.colors.primary,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.3,
    shadowRadius: 16,
    elevation: 8,
  },
  title: {
    fontSize: 34,
    fontWeight: '700',
    color: theme.colors.textPrimary,
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: theme.colors.sectionHeader,
  },
});
