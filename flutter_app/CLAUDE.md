# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Clean Gallery is a modern photo cleanup Flutter app with Material Design 3, featuring swipe-based photo review, smart collections, duplicate detection, and safe deletion workflows. Originally converted from a React Native app.

## Development Commands

### Building & Running
```bash
# Get dependencies
flutter pub get

# Run app (iOS/Android auto-detected)
flutter run

# Clean build (when dependencies or native code changes)
flutter clean && flutter pub get

# Build release APK
flutter build apk --release

# Build iOS release
flutter build ios --release
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test

# Run single test file
flutter test test/path/to/test_file.dart
```

## Architecture

### Clean Architecture + Feature-First Structure

The codebase follows a feature-first organization with clean architecture principles:

```
lib/
├── app/                    # App-level configuration
│   ├── app.dart           # MaterialApp with M3 theme
│   ├── router.dart        # GoRouter with ShellRoute for bottom nav
│   └── main_scaffold.dart # Bottom navigation wrapper
├── core/                   # Cross-cutting concerns
│   ├── theme/             # Material Design 3 theme & colors
│   ├── constants/         # App-wide constants
│   └── widgets/           # Reusable UI components
├── features/              # Feature modules (domain-driven)
│   ├── home/              # Dashboard with stats
│   ├── photos/            # Photo grid, swipe review, filters
│   ├── duplicates/        # Duplicate detection
│   └── storage/           # Storage analytics
└── shared/                # Shared across features
    ├── services/          # PhotoService, PermissionService, StorageService
    └── providers/         # Shared Riverpod providers
```

### Key Architectural Patterns

**Navigation**: GoRouter with ShellRoute for persistent bottom navigation (`/home`, `/photos`) and full-screen modal routes for focused workflows (`/swipe-review`, `/duplicates`, `/confirm-delete`).

**State Management**: Riverpod throughout. Each feature has domain/providers for state. Critical providers:
- `deleteQueueProvider` - Set<String> of photo IDs marked for deletion (StateNotifier)
- `filterProvider` - PhotoFilter state for date, type, size, sort filters (StateNotifier)
- `monthPhotosProvider` - AsyncValue with photos grouped by month
- `homeStatsProvider` - AsyncValue with dashboard statistics

**Photo Access**: `photo_manager` package via `PhotoService`. All photo operations go through this service. Key methods: `getAllPhotos()`, `getPhotoCount()`, `deleteAssets()`. Pagination defaults to 100 photos per page.

**Deletion Flow**: Photos added to `deleteQueueProvider` → User reviews in `/confirm-delete` screen → Multiple confirmation steps → PhotoService.deleteAssets() → Queue cleared. Safe by design.

**Month-Based Organization**: Photos screen displays month bands (e.g., "January 2026") that navigate to swipe review filtered by month. Uses monthKey format (YYYY-MM) for filtering.

## Photo Management

### PhotoService (/Users/saeed/Documents/code/phakhtoons/swipe to clean/flutter_app/lib/shared/services/photo_service.dart)

Central service for all photo operations. Uses `photo_manager` package under the hood.

Key concepts:
- **AssetEntity**: Core photo_manager type representing a photo/video
- **AssetPathEntity**: Represents an album/collection
- **Pagination**: Always paginated (page/size params)
- **Permission**: Must request before accessing photos

Common patterns:
```dart
// Get photos with pagination
final photos = await photoService.getAllPhotos(page: 0, size: 100);

// Delete photos
final photoIds = await photoService.deleteAssets([asset1, asset2]);

// Check if screenshot
final isScreenshot = photoService.isScreenshot(asset);
```

## UI & Design System

### Material Design 3

**Theme**: Dark theme only. Defined in `lib/core/theme/app_theme.dart`.

**Color Palette** (`AppColors`):
- Primary: Blue (#3B82F6) - Main actions, selected states
- Secondary: Teal (#14B8A6) - Accents
- Tertiary: Pink (#EC4899) - Highlights
- Background: Pure black (#000000)
- Surface: Dark gray (#1A1A1A) - Cards, sheets
- Text: Primary (white), Secondary (muted)

**Typography**: Material Design 3 type scale (Display, Headline, Title, Body, Label variants).

**Components**: Heavily customized button themes (elevated, text, outlined), cards with 16px radius, bottom sheets with 20px top radius, 64px navigation bar.

### Swipe Review Screen

Tinder-style card swiper using `flutter_card_swiper` package. Primary interaction model:
- Swipe right/tap checkmark: Keep photo
- Swipe left/tap X: Add to delete queue
- Swipe up/tap info: View details
- Bottom action bar with undo, skip, batch actions

Filtering via query params: `/swipe-review?filter=recents|random|today` or `/swipe-review?month=YYYY-MM`.

## Platform Configuration

### iOS Permissions

Configured in `ios/Runner/Info.plist`:
- `NSPhotoLibraryUsageDescription` - Read access
- `NSPhotoLibraryAddUsageDescription` - Write access

CocoaPods used for dependency management. Run `cd ios && pod install` after adding native dependencies.

### Android Permissions

Configured in `android/app/src/main/AndroidManifest.xml`:
- `READ_MEDIA_IMAGES` - Android 13+ (API 33+)
- `READ_EXTERNAL_STORAGE` - Android 12 and below (API 32-)

Min SDK: 21, Target SDK: Check android/app/build.gradle

## Common Patterns

### Adding a Provider

1. Create in feature's `domain/providers/` directory
2. Use StateNotifier for mutable state, Provider for computed/async values
3. Import in screens with `ref.watch()` for listening, `ref.read()` for one-time reads

### Navigation

Use `context.go()` for tab navigation (home/photos), `context.push()` for modal screens. Pass complex data via `state.extra` as Map<String, dynamic>.

### Working with Photos

Always work with `AssetEntity` from photo_manager. To display images, use `photo_manager_image_provider` package or `AssetEntityImageProvider`. Never assume file paths are available synchronously.

### Filter Patterns

Filters live in `filterProvider`. To apply filters, watch the provider and filter photo list in UI. Date filtering uses DateTime ranges, size filtering uses byte thresholds, sorting uses enum-based sort keys.

## Dependencies

**Core**:
- flutter_riverpod ^2.6.1 - State management
- go_router ^15.0.0 - Routing with deep links
- photo_manager ^3.6.0 - Photo library access

**UI**:
- flutter_card_swiper ^7.0.1 - Swipe cards (review screen)
- flutter_staggered_grid_view ^0.7.0 - Grid layouts
- shimmer ^3.0.0 - Loading skeletons
- animations ^2.0.11 - Shared element transitions

**Utilities**:
- permission_handler ^11.3.1 - Runtime permissions
- shared_preferences ^2.3.3 - Local storage
- intl ^0.19.0 - Date/number formatting

## Features Status

**Implemented**:
- Home dashboard with statistics
- Month-based photo browsing
- Swipe review with card interface
- Delete queue with multi-step confirmation
- Advanced filters (date, size, type, sort)
- Material Design 3 dark theme

**Coming Soon** (UI scaffolded but incomplete):
- Smart collections (Large Files, Old Photos, Screenshots, Similar Photos)
- Duplicate detection algorithm
- Photo compression
- Recently deleted with 30-day retention
- AI-powered suggestions

When adding new features, follow the existing feature-first structure: create feature folder with domain/providers and presentation/screens subdirectories.
