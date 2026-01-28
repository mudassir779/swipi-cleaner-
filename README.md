# Clean Gallery

A beautiful, safe photo gallery cleaner app built with React Native and Expo.

## Overview

Clean Gallery helps users manually review and remove photos from their gallery to free storage. The app never deletes photos automatically - users are always in control.

## Features

- **Photo Library Grid**: Browse all photos in a familiar grid layout similar to Apple Photos
- **Tap Selection**: Tap photos to mark/unmark them for deletion
- **Swipe Review Mode**: Quickly review photos by swiping left (delete) or right (keep)
- **Delete Queue**: Review all selected photos before deletion
- **Safe Deletion**: Multiple confirmation steps before permanent deletion
- **Dark/Light Mode**: Supports system theme preferences

## User Flow

1. **Onboarding**: Welcome screen explaining app functionality
2. **Permission**: Request photo access permission
3. **Library**: Browse photos in grid view
4. **Selection**: Tap or swipe to select photos for deletion
5. **Queue Review**: Review selected photos
6. **Confirmation**: Explicit confirmation before deletion
7. **Success**: Confirmation of freed storage

## Tech Stack

- Expo SDK 53
- React Native 0.76.7
- TypeScript
- NativeWind (TailwindCSS)
- Zustand (State Management)
- React Query (Async State)
- React Native Reanimated (Animations)
- React Native Gesture Handler (Gestures)

## Project Structure

```
src/
├── app/                    # Expo Router screens
│   ├── (tabs)/            # Tab navigator screens
│   │   ├── index.tsx      # Library (photo grid)
│   │   ├── queue.tsx      # Delete queue
│   │   └── settings.tsx   # App settings
│   ├── onboarding/        # Onboarding flow
│   ├── confirm-delete.tsx # Deletion confirmation
│   ├── success.tsx        # Success screen
│   └── swipe-review.tsx   # Swipe review mode
├── components/            # Reusable components
└── lib/
    └── state/
        └── gallery-store.ts # Zustand store
```

## Key Screens

### Library
- Grid view of all photos (3 columns)
- Long press to enter selection mode
- Tap to select/deselect photos
- "Swipe" button for fast review mode

### Delete Queue
- Shows all photos marked for deletion
- Estimated storage to be freed
- Tap to remove from queue
- "Review & Delete" button

### Swipe Review
- Tinder-style card swipe interface
- Swipe left = add to delete queue
- Swipe right = keep photo
- Manual buttons for accessibility

### Settings
- Manage Subscription
- Privacy Policy
- Terms of Service
- Contact Support
- Photo Access Settings

## Safety Features

- Photos are NEVER deleted automatically
- Users must explicitly select photos
- Multiple confirmation steps before deletion
- Clear visual indicators of what will be deleted
- iOS system confirmation dialog for final deletion
