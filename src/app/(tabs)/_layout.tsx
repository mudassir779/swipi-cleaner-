import React from 'react';
import { Tabs } from 'expo-router';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Platform } from 'react-native';
import { theme } from '@/lib/theme';

export default function TabLayout() {
  const insets = useSafeAreaInsets();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.sectionHeader,
        tabBarStyle: {
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: theme.colors.background,
          borderTopWidth: 1,
          borderTopColor: theme.colors.border,
          height: Platform.OS === 'web' ? 70 : 60 + insets.bottom,
          paddingTop: 8,
          paddingBottom: Platform.OS === 'web' ? 12 : insets.bottom,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: 0.3,
          shadowRadius: 8,
          elevation: 8,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '500',
          marginTop: 2,
        },
      }}
    >
      {/* Home - Cleanup Dashboard */}
      <Tabs.Screen
        name="home"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? "home" : "home-outline"} size={24} color={color} />
          ),
        }}
      />

      {/* Albums - Date/Source organization */}
      <Tabs.Screen
        name="albums"
        options={{
          title: 'Albums',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? "albums" : "albums-outline"} size={24} color={color} />
          ),
        }}
      />

      {/* Tools - Compress, PDF, etc. */}
      <Tabs.Screen
        name="tools"
        options={{
          title: 'Tools',
          tabBarIcon: ({ color, focused }) => (
            <MaterialIcons name="auto-fix-high" size={24} color={color} />
          ),
        }}
      />

      {/* Photos - Browse all media */}
      <Tabs.Screen
        name="index"
        options={{
          title: 'Photos',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? "images" : "images-outline"} size={24} color={color} />
          ),
        }}
      />

      {/* Profile/Settings */}
      <Tabs.Screen
        name="settings"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? "person" : "person-outline"} size={24} color={color} />
          ),
        }}
      />

      {/* Hidden screens */}
      <Tabs.Screen
        name="queue"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="two"
        options={{
          href: null,
        }}
      />
    </Tabs>
  );
}
