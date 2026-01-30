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
import '../features/storage/presentation/storage_overview_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/premium/presentation/premium_upgrade_screen.dart';
import '../features/success/domain/models/cleanup_success_result.dart';
import '../features/success/presentation/cleanup_success_screen.dart';
import '../features/home/presentation/home_screen.dart';

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

      // Main tab screens
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/photos',
        name: 'photos',
        builder: (context, state) => const PhotosScreen(),
      ),
      GoRoute(
        path: '/tools',
        name: 'tools',
        builder: (context, state) => const ToolsScreen(),
      ),

      // Full-screen modal routes
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
        path: '/compress-photos',
        name: 'compress-photos',
        builder: (context, state) => const CompressPhotosScreen(),
      ),
      GoRoute(
        path: '/create-pdf',
        name: 'create-pdf',
        builder: (context, state) => const CreatePdfScreen(),
      ),
      GoRoute(
        path: '/video-frames',
        name: 'video-frames',
        builder: (context, state) => const VideoFramesScreen(),
      ),
      GoRoute(
        path: '/compress-videos',
        name: 'compress-videos',
        builder: (context, state) => const VideoCompressionScreen(),
      ),
      GoRoute(
        path: '/storage-stats',
        name: 'storage-stats',
        builder: (context, state) => const StorageOverviewScreen(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumUpgradeScreen(),
      ),
      GoRoute(
        path: '/recently-deleted',
        name: 'recently-deleted',
        builder: (context, state) => const RecentlyDeletedScreen(),
      ),
      GoRoute(
        path: '/confirm-delete',
        name: 'confirm-delete',
        builder: (context, state) => const ConfirmDeleteScreen(),
      ),
      GoRoute(
        path: '/success',
        name: 'success',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is CleanupSuccessResult) {
            return CleanupSuccessScreen(result: extra);
          }
          // Fall back to a safe default if navigation data is missing.
          return const CleanupSuccessScreen(
            result: CleanupSuccessResult(itemsDeleted: 0, bytesFreed: 0),
          );
        },
      ),
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
