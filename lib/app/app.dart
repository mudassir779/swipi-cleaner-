import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/domain/providers/settings_provider.dart';
import 'router.dart';

/// Main app widget with Material Design 3 theme and dynamic theme switching
class CleanGalleryApp extends ConsumerWidget {
  const CleanGalleryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    // Default to light theme while loading
    final isDarkMode = settingsAsync.valueOrNull?.isDarkMode ?? false;

    return MaterialApp.router(
      title: 'Swipe to Clean Storage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
