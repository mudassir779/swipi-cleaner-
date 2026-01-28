import React, { useEffect } from 'react';
import { Text, StyleSheet, Pressable } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSpring,
} from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useToastStore, ToastType } from '@/lib/state/toast-store';
import { theme } from '@/lib/theme';

const TOAST_ICONS: Record<ToastType, { name: string; color: string }> = {
  success: { name: 'checkmark-circle', color: theme.colors.primary },
  error: { name: 'close-circle', color: theme.colors.red },
  info: { name: 'information-circle', color: theme.colors.blue },
};

export function Toast() {
  const insets = useSafeAreaInsets();
  const { visible, message, type, hideToast } = useToastStore();
  
  // Animation values
  const translateY = useSharedValue(-100);
  const opacity = useSharedValue(0);

  useEffect(() => {
    if (visible) {
      // Slide in from top
      translateY.value = withSpring(0, { damping: 15, stiffness: 150 });
      opacity.value = withTiming(1, { duration: 200 });
    } else {
      // Slide out to top
      translateY.value = withTiming(-100, { duration: 200 });
      opacity.value = withTiming(0, { duration: 200 });
    }
  }, [visible]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }],
    opacity: opacity.value,
  }));

  const iconConfig = TOAST_ICONS[type];

  if (!visible && opacity.value === 0) {
    return null;
  }

  return (
    <Animated.View
      style={[
        styles.container,
        { top: insets.top + 10 },
        animatedStyle,
      ]}
      pointerEvents={visible ? 'auto' : 'none'}
    >
      <Pressable
        onPress={hideToast}
        style={styles.toastContent}
      >
        <Ionicons
          name={iconConfig.name as any}
          size={22}
          color={iconConfig.color}
          style={styles.icon}
        />
        <Text style={styles.message} numberOfLines={2}>
          {message}
        </Text>
        <Ionicons
          name="close"
          size={18}
          color={theme.colors.textSecondary}
        />
      </Pressable>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    left: 16,
    right: 16,
    zIndex: 9999,
  },
  toastContent: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 8,
  },
  icon: {
    marginRight: 12,
  },
  message: {
    flex: 1,
    fontSize: 15,
    fontWeight: '500',
    color: '#1F2937',
  },
});
