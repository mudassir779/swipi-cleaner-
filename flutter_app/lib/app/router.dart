import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/photos/presentation/photos_screen.dart';
import '../features/photos/presentation/screens/confirm_delete_screen.dart';
import '../features/photos/presentation/screens/photo_details_screen.dart';
import '../features/photos/presentation/screens/recently_deleted_screen.dart';
import '../features/photos/presentation/screens/swipe_review_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tools/presentation/screens/duplicates_screen.dart';
import '../features/tools/presentation/screens/smart_collections_screen.dart';
import '../features/tools/presentation/tools_screen.dart';
import 'main_scaffold.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/photos',
            name: 'photos',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PhotosScreen(),
            ),
          ),
          GoRoute(
            path: '/tools',
            name: 'tools',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ToolsScreen(),
            ),
          ),
        ],
      ),

      // Modal routes (full-screen)
      GoRoute(
        path: '/swipe-review',
        name: 'swipe-review',
        builder: (context, state) => const SwipeReviewScreen(),
      ),
      GoRoute(
        path: '/duplicates',
        name: 'duplicates',
        builder: (context, state) => const DuplicatesScreen(),
      ),
      GoRoute(
        path: '/smart-collections',
        name: 'smart-collections',
        builder: (context, state) => const SmartCollectionsScreen(),
      ),
      GoRoute(
        path: '/confirm-delete',
        name: 'confirm-delete',
        builder: (context, state) => const ConfirmDeleteScreen(),
      ),
      GoRoute(
        path: '/recently-deleted',
        name: 'recently-deleted',
        builder: (context, state) => const RecentlyDeletedScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/photo-details',
        name: 'photo-details',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MaterialPage(
            fullscreenDialog: true,
            child: PhotoDetailsScreen(
              asset: extra['asset'] as AssetEntity,
              photoId: extra['photoId'] as String,
            ),
          );
        },
      ),
    ],
  );
}
