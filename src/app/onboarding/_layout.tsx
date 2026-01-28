import { Stack } from 'expo-router';
import { useColorScheme } from '@/lib/useColorScheme';

export default function OnboardingLayout() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: {
          backgroundColor: isDark ? '#0a0a0a' : '#f8fafc',
        },
        animation: 'slide_from_right',
      }}
    >
      <Stack.Screen name="index" />
      <Stack.Screen name="permission-education" />
      <Stack.Screen name="photo-access" />
    </Stack>
  );
}
