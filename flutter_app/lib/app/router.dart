import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/photos/presentation/photos_screen.dart';
import '../features/photos/presentation/screens/confirm_delete_screen.dart';
import '../features/photos/presentation/screens/photo_details_screen.dart';
import '../features/photos/presentation/screens/swipe_review_screen.dart';
import '../features/duplicates/presentation/duplicates_screen.dart';
import '../features/storage/presentation/storage_overview_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/premium/presentation/premium_upgrade_screen.dart';
import '../features/success/domain/models/cleanup_success_result.dart';
import '../features/success/presentation/cleanup_success_screen.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main screen - Month list
      GoRoute(
        path: '/photos',
        name: 'photos',
        builder: (context, state) => const PhotosScreen(),
      ),

      // Swipe Review - Vertical shared axis transition
      GoRoute(
        path: '/swipe-review',
        name: 'swipe-review',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SwipeReviewScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
        ),
      ),

      // Duplicates - Horizontal shared axis transition
      GoRoute(
        path: '/duplicates',
        name: 'duplicates',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DuplicatesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/storage-stats',
        name: 'storage-stats',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StorageOverviewScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CategoriesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PremiumUpgradeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/success',
        name: 'success',
        pageBuilder: (context, state) {
          final extra = state.extra;
          final result = extra is CleanupSuccessResult
              ? extra
              : const CleanupSuccessResult(itemsDeleted: 0, bytesFreed: 0);
          return CustomTransitionPage(
            key: state.pageKey,
            child: CleanupSuccessScreen(result: result),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
          );
        },
      ),

      // Confirm Delete - Fade through transition
      GoRoute(
        path: '/confirm-delete',
        name: 'confirm-delete',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ConfirmDeleteScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        ),
      ),

      // Photo Details - Fade scale transition
      GoRoute(
        path: '/photo-details',
        name: 'photo-details',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null || !extra.containsKey('asset') || !extra.containsKey('photoId')) {
            // Return error page if navigation data is missing
            return MaterialPage(
              child: Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid photo details'),
                ),
              ),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: PhotoDetailsScreen(
              asset: extra['asset'] as AssetEntity,
              photoId: extra['photoId'] as String,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeScaleTransition(
                animation: animation,
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
}
