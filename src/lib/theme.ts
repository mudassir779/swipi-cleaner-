/**
 * Dark Theme Configuration
 * Centralized color palette for the Photo Cleanup app
 */

export const theme = {
  colors: {
    // Base colors
    background: '#000000',
    surface: '#1A1A1A',
    surfaceLight: '#2A2A2A',
    
    // Text colors
    textPrimary: '#FFFFFF',
    textSecondary: '#9CA3AF',
    sectionHeader: '#6B7280',
    
    // Border colors
    border: '#1F1F1F',
    borderLight: '#333333',
    
    // Accent colors (kept vibrant for cards)
    primary: '#3B82F6',
    teal: '#14B8A6',
    tealDark: '#0D9488',
    orange: '#F97316',
    orangeDark: '#EA580C',
    pink: '#EC4899',
    pinkDark: '#DB2777',
    purple: '#8B5CF6',
    purpleDark: '#7C3AED',
    blue: '#3B82F6',
    blueDark: '#2563EB',
    yellow: '#F59E0B',
    yellowDark: '#D97706',
    gray: '#6B7280',
    grayDark: '#4B5563',
    red: '#EF4444',
    redDark: '#DC2626',
    green: '#10B981',
    greenDark: '#059669',
    
    // Gradients (for easy access)
    gradients: {
      teal: ['#14B8A6', '#0D9488'] as [string, string],
      orange: ['#F97316', '#EA580C'] as [string, string],
      pink: ['#EC4899', '#DB2777'] as [string, string],
      purple: ['#8B5CF6', '#7C3AED'] as [string, string],
      blue: ['#3B82F6', '#2563EB'] as [string, string],
      yellow: ['#F59E0B', '#D97706'] as [string, string],
      gray: ['#6B7280', '#4B5563'] as [string, string],
      red: ['#EF4444', '#DC2626'] as [string, string],
      green: ['#10B981', '#059669'] as [string, string],
      indigo: ['#6366F1', '#4F46E5'] as [string, string],
    },
    
    // Stats card background colors
    stats: {
      photos: '#1E3A5F', // Blue tint
      videos: '#2D1F4E', // Purple tint
      today: '#1A3D2E', // Green tint
      toDelete: '#3D1F1F', // Red tint
    },
  },
  
  spacing: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
    xxl: 24,
  },
  
  borderRadius: {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
    full: 9999,
  },
  
  typography: {
    title: {
      fontSize: 34,
      fontWeight: '700' as const,
    },
    subtitle: {
      fontSize: 16,
      fontWeight: '400' as const,
    },
    sectionHeader: {
      fontSize: 13,
      fontWeight: '600' as const,
      textTransform: 'uppercase' as const,
      letterSpacing: 0.5,
    },
    cardTitle: {
      fontSize: 18,
      fontWeight: '700' as const,
    },
    cardSubtitle: {
      fontSize: 13,
      fontWeight: '400' as const,
    },
    statValue: {
      fontSize: 20,
      fontWeight: '700' as const,
    },
    statLabel: {
      fontSize: 12,
      fontWeight: '400' as const,
    },
  },
} as const;

export type Theme = typeof theme;
