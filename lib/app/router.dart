import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/photos/presentation/photos_screen.dart';
import '../features/photos/presentation/screens/confirm_delete_screen.dart';
import '../features/photos/presentation/screens/photo_details_screen.dart';
import '../features/photos/presentation/screens/swipe_review_screen.dart';
import '../features/photos/presentation/screens/recently_deleted_screen.dart';
import '../features/duplicates/presentation/duplicates_screen.dart';
import '../features/tools/presentation/tools_screen.dart';
import '../features/tools/presentation/screens/compress_photos_screen.dart';
import '../features/tools/presentation/screens/create_pdf_screen.dart';
import '../features/tools/presentation/screens/video_frames_screen.dart';
import '../features/tools/presentation/screens/video_compression_screen.dart';
import '../features/tools/presentation/screens/smart_collections_screen.dart';
import '../features/tools/presentation/screens/collection_photos_screen.dart';
import '../features/tools/presentation/screens/social_media_cleaner_screen.dart';
import '../features/storage/presentation/storage_overview_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/premium/presentation/premium_upgrade_screen.dart';
import '../features/success/domain/models/cleanup_success_result.dart';
import '../features/success/presentation/cleanup_success_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// Custom page transitions for smooth navigation
class _FadeTransitionPage extends CustomTransitionPage<void> {
  _FadeTransitionPage({required Widget child})
      : super(
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}

class _SlideUpTransitionPage extends CustomTransitionPage<void> {
  _SlideUpTransitionPage({required Widget child})
      : super(
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}

class _SlideRightTransitionPage extends CustomTransitionPage<void> {
  _SlideRightTransitionPage({required Widget child})
      : super(
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// App routing configuration using GoRouter with smooth animations
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Onboarding - Fade transition
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _FadeTransitionPage(
          child: const OnboardingScreen(),
        ),
      ),

      // Main tab screens - Fade transition for smooth tab switching
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _FadeTransitionPage(
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/photos',
        name: 'photos',
        pageBuilder: (context, state) => _FadeTransitionPage(
          child: const PhotosScreen(),
        ),
      ),
      GoRoute(
        path: '/tools',
        name: 'tools',
        pageBuilder: (context, state) => _FadeTransitionPage(
          child: const ToolsScreen(),
        ),
      ),

      // Full-screen modal routes - Slide up animation
      GoRoute(
        path: '/swipe-review',
        name: 'swipe-review',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const SwipeReviewScreen(),
        ),
      ),
      GoRoute(
        path: '/duplicates',
        name: 'duplicates',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const DuplicatesScreen(),
        ),
      ),
      GoRoute(
        path: '/smart-collections',
        name: 'smart-collections',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const SmartCollectionsScreen(),
        ),
      ),
      GoRoute(
        path: '/compress-photos',
        name: 'compress-photos',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const CompressPhotosScreen(),
        ),
      ),
      GoRoute(
        path: '/create-pdf',
        name: 'create-pdf',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const CreatePdfScreen(),
        ),
      ),
      GoRoute(
        path: '/video-frames',
        name: 'video-frames',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const VideoFramesScreen(),
        ),
      ),
      GoRoute(
        path: '/compress-videos',
        name: 'compress-videos',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const VideoCompressionScreen(),
        ),
      ),
      GoRoute(
        path: '/collection-photos/:type',
        name: 'collection-photos',
        pageBuilder: (context, state) {
          final typeStr = state.pathParameters['type'] ?? 'large';
          CollectionType type;
          switch (typeStr) {
            case 'old':
              type = CollectionType.old;
              break;
            case 'screenshots':
              type = CollectionType.screenshots;
              break;
            default:
              type = CollectionType.large;
          }
          return _SlideRightTransitionPage(
            child: CollectionPhotosScreen(collectionType: type),
          );
        },
      ),
      GoRoute(
        path: '/social-media-cleaner',
        name: 'social-media-cleaner',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const SocialMediaCleanerScreen(),
        ),
      ),
      GoRoute(
        path: '/storage-stats',
        name: 'storage-stats',
        pageBuilder: (context, state) => _SlideRightTransitionPage(
          child: const StorageOverviewScreen(),
        ),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        pageBuilder: (context, state) => _SlideRightTransitionPage(
          child: const CategoriesScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => _SlideRightTransitionPage(
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const PremiumUpgradeScreen(),
        ),
      ),
      GoRoute(
        path: '/recently-deleted',
        name: 'recently-deleted',
        pageBuilder: (context, state) => _SlideRightTransitionPage(
          child: const RecentlyDeletedScreen(),
        ),
      ),
      GoRoute(
        path: '/confirm-delete',
        name: 'confirm-delete',
        pageBuilder: (context, state) => _SlideUpTransitionPage(
          child: const ConfirmDeleteScreen(),
        ),
      ),
      GoRoute(
        path: '/success',
        name: 'success',
        pageBuilder: (context, state) {
          final extra = state.extra;
          Widget child;
          if (extra is CleanupSuccessResult) {
            child = CleanupSuccessScreen(result: extra);
          } else {
            child = const CleanupSuccessScreen(
              result: CleanupSuccessResult(itemsDeleted: 0, bytesFreed: 0),
            );
          }
          return _FadeTransitionPage(child: child);
        },
      ),
      GoRoute(
        path: '/photo-details',
        name: 'photo-details',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null || !extra.containsKey('asset') || !extra.containsKey('photoId')) {
            return MaterialPage(
              child: Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid photo details'),
                ),
              ),
            );
          }
          return _SlideUpTransitionPage(
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
