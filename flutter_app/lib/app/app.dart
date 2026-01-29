import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

/// Main app widget with Material Design 3 theme
class CleanGalleryApp extends StatelessWidget {
  const CleanGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Swipple : swipe to clean',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
