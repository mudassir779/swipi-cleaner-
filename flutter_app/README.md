# Clean Gallery - Flutter App

A modern photo cleanup app built with Flutter and Material Design 3. Helps users organize and clean their photo library with smart features and an intuitive interface.

## Features

### ✅ Implemented
- **Home Dashboard** - Statistics cards showing photos, videos, today's captures, and delete queue
- **Photo Grid** - 3-column grid with selection mode and filtering
- **Swipe Review** - Tinder-style card swiper for quick photo review
- **Smart Collections** - Auto-categorized photos (Large Files, Old Photos, Screenshots, Similar Photos)
- **Find Duplicates** - Duplicate photo detection (UI ready, detection coming soon)
- **Advanced Filters** - Date range, file size, and sorting options
- **Delete Queue** - Safe deletion with multiple confirmation steps
- **Material Design 3** - Modern dark theme with smooth animations

### 🚧 Coming Soon
- Photo compression
- PDF creation
- Video frames extraction
- AI-powered suggestions
- Recently deleted recovery (30-day retention)
- Actual duplicate detection algorithm

## Tech Stack

- **Flutter** 3.10+
- **Dart** 3.0+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Photo Access**: photo_manager
- **UI Components**: Material Design 3
- **Animations**: flutter_card_swiper

## Architecture

### Clean Architecture + Feature-First

```
lib/
├── app/                    # App configuration
│   ├── app.dart           # MaterialApp with theme
│   ├── router.dart        # GoRouter configuration
│   └── main_scaffold.dart # Bottom navigation scaffold
├── core/                   # Core utilities
│   ├── theme/             # Material Design 3 theme
│   ├── constants/         # App constants
│   └── widgets/           # Reusable widgets
├── features/               # Feature modules
│   ├── home/              # Dashboard
│   ├── photos/            # Photo grid & swipe review
│   └── tools/             # Tools & utilities
└── shared/                 # Shared services
    ├── services/          # Photo, storage, permissions
    └── providers/         # Shared providers
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- iOS development: Xcode 14+, CocoaPods
- Android development: Android Studio, Android SDK 21+

### Installation

1. Clone the repository:
```bash
cd flutter_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on iOS:
```bash
flutter run
```

4. Run on Android:
```bash
flutter run
```

### Permissions

**iOS** - Photo library access is configured in `ios/Runner/Info.plist`:
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription

**Android** - Permissions in `android/app/src/main/AndroidManifest.xml`:
- READ_MEDIA_IMAGES (Android 13+)
- READ_EXTERNAL_STORAGE (Android 12 and below)

## Development

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test
```

### Key Commands

```bash
# Clean build
flutter clean && flutter pub get

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Navigation Structure

**3 Main Tabs:**
1. **Home** - Dashboard with stats and quick actions
2. **Photos** - Photo grid with filters and selection
3. **Tools** - Utilities for cleanup and optimization

**Modal Routes:**
- `/swipe-review` - Card swiper interface
- `/duplicates` - Duplicate detection
- `/smart-collections` - Auto-categorized collections

## State Management

**Riverpod Providers:**
- `photoProvider` - Photo list with pagination
- `deleteQueueProvider` - Photos marked for deletion
- `filterProvider` - Active filters and sorting
- `homeStatsProvider` - Dashboard statistics

## Design System

**Colors:**
- Primary: Blue (#3B82F6)
- Secondary: Teal (#14B8A6)
- Tertiary: Pink (#EC4899)
- Background: Black (#000000)
- Surface: Dark Gray (#1A1A1A)

**Typography:**
- Display, Headline, Title, Body, Label variants
- Material Design 3 type scale

## Performance

- **Lazy loading** with pagination (100 photos per page)
- **Image caching** via photo_manager
- **Optimized grid rendering** with 3-column layout
- **Smooth 60fps animations**

## Contributing

This is a personal project converted from React Native to Flutter. For major changes, please open an issue first.

## License

Private project - All rights reserved

## Acknowledgments

- Original React Native app design
- Material Design 3 guidelines
- Flutter community packages
