// Override useColorScheme to always return 'dark' for the Photo Cleanup app
// This ensures consistent dark theme experience across the app
export function useColorScheme(): 'dark' | 'light' {
  return 'dark';
}
