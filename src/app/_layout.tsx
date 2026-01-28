import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import { useColorScheme } from '@/lib/useColorScheme';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import React, { useEffect, useState, useRef } from 'react';

// Conditionally import KeyboardProvider to handle cases where native module isn't linked
let KeyboardProvider: React.ComponentType<{ children: React.ReactNode }>;
try {
  const keyboardController = require('react-native-keyboard-controller');
  KeyboardProvider = keyboardController.KeyboardProvider;
} catch (error) {
  console.warn('react-native-keyboard-controller not available, using fallback');
  // Fallback: just pass through children
  KeyboardProvider = ({ children }: { children: React.ReactNode }) => <>{children}</>;
}
import { useGalleryStore } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import { useRouter, useSegments } from 'expo-router';
import { View, ActivityIndicator } from 'react-native';
import { Toast } from '@/components/Toast';

export const unstable_settings = {
  initialRouteName: 'splash',
};

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

const queryClient = new QueryClient();

function RootLayoutNav({ colorScheme }: { colorScheme: 'light' | 'dark' | null | undefined }) {
  // Always use dark theme
  return (
    <ThemeProvider value={DarkTheme}>
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: {
            backgroundColor: '#000000',
          },
        }}
      >
        <Stack.Screen 
          name="splash" 
          options={{
            animation: 'fade',
          }}
        />
        <Stack.Screen name="(tabs)" />
        <Stack.Screen
          name="onboarding"
          options={{
            animation: 'fade',
          }}
        />
        <Stack.Screen
          name="confirm-delete"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="success"
          options={{
            animation: 'fade',
            gestureEnabled: false,
          }}
        />
        <Stack.Screen
          name="swipe-review"
          options={{
            presentation: 'fullScreenModal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="photo-details"
          options={{
            presentation: 'fullScreenModal',
            animation: 'fade',
          }}
        />
        <Stack.Screen
          name="duplicates"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="recently-deleted"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="smart-collections"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="photo-comparison"
          options={{
            presentation: 'fullScreenModal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="ai-suggestions"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen name="modal" options={{ presentation: 'modal' }} />
        <Stack.Screen
          name="compress"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="create-pdf"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
        <Stack.Screen
          name="video-frames"
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
      </Stack>
    </ThemeProvider>
  );
}

function InitialRouteHandler() {
  const router = useRouter();
  const segments = useSegments();
  const [isLoading, setIsLoading] = useState(true);
  const hasCompletedOnboarding = useGalleryStore((s) => s.hasCompletedOnboarding);
  const hasChecked = useRef(false);

  useEffect(() => {
    // Only run once on mount, not when hasCompletedOnboarding changes
    if (hasChecked.current) return;
    
    async function checkInitialRoute() {
      try {
        // Check if we have photo permissions
        const { status } = await MediaLibrary.getPermissionsAsync();
        const hasPermission = status === 'granted';

        // Only navigate if we're on the initial route and need onboarding
        const currentRoute = segments[0];
        if (!hasPermission && !hasCompletedOnboarding && currentRoute !== 'onboarding') {
          router.replace('/onboarding');
        }
      } catch (error) {
        console.error('Error checking permissions:', error);
      } finally {
        setIsLoading(false);
        SplashScreen.hideAsync();
        hasChecked.current = true;
      }
    }

    checkInitialRoute();
  }, []); // Empty dependency array - only run once on mount

  if (isLoading) {
    return null;
  }

  return null;
}

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
    <QueryClientProvider client={queryClient}>
      <GestureHandlerRootView style={{ flex: 1 }}>
        <KeyboardProvider>
          <StatusBar style="light" />
          <RootLayoutNav colorScheme={colorScheme} />
          <InitialRouteHandler />
          <Toast />
        </KeyboardProvider>
      </GestureHandlerRootView>
    </QueryClientProvider>
  );
}
