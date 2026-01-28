# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Clean Gallery** - A photo gallery cleaner app built with Expo and React Native. Users can review and manually delete photos from their gallery to free up storage. The app emphasizes safety with multiple confirmation steps and never deletes photos automatically.

## Tech Stack

- **Expo SDK 53** with React Native 0.76.7
- **Package Manager**: npm (NOT bun - despite any mentions in old docs)
- **Styling**: NativeWind (Tailwind v3) + centralized theme in `src/lib/theme.ts`
- **State Management**:
  - Zustand for local state (`src/lib/state/gallery-store.ts`)
  - React Query for server/async state
- **Animations**: react-native-reanimated v3 (preferred over Animated)
- **Gestures**: react-native-gesture-handler
- **Navigation**: Expo Router (file-based routing)

## Common Commands

```bash
# Start development server
npm start

# Clear cache and restart (use when Metro bundler has issues)
npx expo start --clear

# Type checking
npx tsc --noEmit

# Linting
npm run lint

# Run on iOS
npm run ios

# Run on Android
npm run android
```

## Project Structure

```
src/
├── app/                           # Expo Router screens (file-based routing)
│   ├── _layout.tsx               # Root layout with QueryClient, GestureHandler, KeyboardProvider
│   ├── splash.tsx                # Initial splash screen
│   ├── (tabs)/                   # Tab navigator (5 tabs: home, albums, tools, photos, profile)
│   │   ├── _layout.tsx           # Tab bar configuration
│   │   ├── home.tsx              # Main cleanup dashboard
│   │   ├── albums.tsx            # Date/source organization
│   │   ├── tools.tsx             # Compress, PDF, etc.
│   │   ├── index.tsx             # Photo grid/library (main browsing)
│   │   ├── settings.tsx          # User settings/profile
│   │   └── queue.tsx             # Delete queue (hidden from tabs via href: null)
│   ├── photo-details.tsx         # Full-screen photo details modal
│   ├── swipe-review.tsx          # Tinder-style swipe interface (fullScreenModal)
│   ├── confirm-delete.tsx        # Delete confirmation modal
│   ├── success.tsx               # Post-deletion success screen
│   ├── recently-deleted.tsx      # Recently deleted photos
│   ├── duplicates.tsx            # Duplicate detection view
│   ├── smart-collections.tsx     # Smart photo collections
│   ├── photo-comparison.tsx      # Side-by-side photo comparison
│   ├── ai-suggestions.tsx        # AI-powered cleanup suggestions
│   ├── compress.tsx              # Photo compression tool
│   ├── create-pdf.tsx            # PDF creation tool
│   └── analytics.tsx             # Usage analytics
│
├── components/                    # Reusable UI components
│   ├── PhotoCard.tsx             # Individual photo grid item
│   ├── StatisticsCard.tsx        # Home dashboard stats cards
│   ├── SearchBar.tsx             # Photo search
│   ├── ModernSearchBar.tsx       # Updated search component
│   ├── DateRangeFilter.tsx       # Date range picker
│   ├── AdvancedFilters.tsx       # Filter panel (type, size, date)
│   ├── SortMenu.tsx              # Sort options menu
│   ├── DuplicateGroup.tsx        # Duplicate photo grouping
│   ├── GlassmorphicCard.tsx      # Glassmorphic design component
│   ├── AnimatedPressable.tsx     # Pressable with animations
│   ├── AnimatedCounter.tsx       # Counter with animations
│   ├── SkeletonLoader.tsx        # Loading skeleton
│   └── Toast.tsx                 # Toast notification system
│
└── lib/
    ├── state/
    │   ├── gallery-store.ts      # Main Zustand store (delete queue, filters, sorting, recently deleted)
    │   ├── toast-store.ts        # Toast notification state
    │   └── example-state.ts      # Example state pattern
    ├── hooks/
    │   ├── usePhotoSearch.ts     # Photo search logic
    │   ├── useStorageStats.ts    # Storage statistics
    │   ├── usePremium.ts         # Premium feature checks
    │   └── useBackupStatus.ts    # Backup status checks
    ├── utils/
    │   ├── duplicateDetection.ts # Duplicate photo detection
    │   ├── aiAnalysis.ts         # AI analysis utilities
    │   └── sourceAppDetection.ts # Detect photo source apps
    ├── theme.ts                  # Centralized dark theme config
    ├── cn.ts                     # className merge utility (tailwind-merge)
    └── useColorScheme.ts         # Color scheme hook
```

## Architecture Patterns

### State Management
- **Zustand** (`gallery-store.ts`): Manages delete queue, selection mode, filters, sorting, and recently deleted photos
  - Persisted: `hasCompletedOnboarding`, `recentlyDeleted` (via AsyncStorage)
  - Ephemeral: delete queue, filters, sorting (cleared on app restart)
  - Always use selectors: `useGalleryStore(s => s.deleteQueue)` not `useGalleryStore()`
- **React Query**: For async operations like photo loading, use `useQuery` and `useMutation` with object API

### Routing Architecture
- Root layout (`_layout.tsx`) sets up providers: QueryClient → GestureHandler → KeyboardProvider → ThemeProvider → Stack
- Initial route handled by `InitialRouteHandler` component which checks onboarding status and permissions
- Tab navigation with 5 visible tabs (home, albums, tools, photos, profile)
- Hidden routes in tabs: `queue.tsx` (accessible via navigation but not in tab bar)
- Modal presentations: `confirm-delete` (modal), `photo-details` (fullScreenModal), `swipe-review` (fullScreenModal)

### Theme System
- Centralized in `src/lib/theme.ts` with dark theme colors, spacing, borderRadius, typography
- NativeWind used for styling but components like `CameraView`, `LinearGradient`, `Animated` require inline `style` prop
- Use `cn()` helper from `src/lib/cn.ts` for conditional className merging

### Photo Management Flow
1. Load photos via `expo-media-library`
2. Display in grid (`index.tsx`) or card view (`swipe-review.tsx`)
3. User selects photos → added to `deleteQueue` in Zustand store
4. Review in queue tab → confirm via `confirm-delete.tsx` modal
5. On deletion → move to `recentlyDeleted` array with 30-day retention
6. Success screen shows freed storage

## Key Features

### Delete Queue System
- Managed in `gallery-store.ts` with methods: `addToDeleteQueue`, `removeFromDeleteQueue`, `toggleInDeleteQueue`
- Supports bulk operations: `selectAll`, `deselectAll`, `invertSelection`
- Queue is NOT persisted (cleared on app restart for safety)

### Recently Deleted
- 30-day retention period before permanent deletion
- Stored in Zustand with persistence via AsyncStorage
- Users can restore photos from this view

### Advanced Filtering
- Date filters: all, today, thisWeek, thisMonth, thisYear, custom range
- Photo type filters: screenshots, selfies, live photos, burst photos
- Size filters: large, medium, small
- Sorting: by date, size, or name (asc/desc)

### Smart Collections
- Duplicates detection (perceptual hashing via `duplicateDetection.ts`)
- Screenshots collection
- Source app detection (WhatsApp, Instagram, Snapchat, etc.)
- AI-powered suggestions for cleanup

## Metro Bundler Troubleshooting

Common errors and solutions documented in `METRO_TROUBLESHOOTING.md`:

**If Metro fails:**
```bash
# Quick fix
npx expo start --clear

# Nuclear option
rm -rf node_modules package-lock.json .expo
npm cache clean --force
npm install --legacy-peer-deps
npx expo start --clear
```

**TransitionPresets errors:** Check `FIX_METRO_TRANSITIONPRESETS.md` for navigation animation fixes

## Important Notes

- **DO NOT** edit: `patches/`, `babel.config.js`, `metro.config.js`, `app.json`, `tsconfig.json`, `nativewind-env.d.ts`
- Always use TypeScript strict mode with explicit type annotations
- Use `expo-media-library` for photo access, requires permissions
- The app is designed for **manual deletion only** - never auto-delete photos
- Dark theme is enforced app-wide (see `_layout.tsx` line 37)
- SafeAreaView is from `react-native-safe-area-context` NOT react-native

## Testing Approach

- Use realistic mock data when real data isn't available
- For image analysis features, integrate with actual AI APIs (don't mock)
- Test deletion flow thoroughly - multiple confirmation steps are critical for user trust
