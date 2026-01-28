import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/permission_service.dart';
import '../../../shared/services/storage_service.dart';

/// Onboarding screen with feature introduction and permission request
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.photo_library,
      iconGradient: AppColors.gradientBlue,
      title: 'Clean Your Gallery',
      description: 'Quickly review and organize your photo library with smart tools',
    ),
    _OnboardingPage(
      icon: Icons.swipe,
      iconGradient: AppColors.gradientTeal,
      title: 'Swipe to Clean',
      description: 'Swipe left to delete, swipe right to keep. Make decisions in seconds',
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome,
      iconGradient: AppColors.gradientPurple,
      title: 'Smart Collections',
      description: 'Find duplicates, screenshots, and large files automatically',
    ),
    _OnboardingPage(
      icon: Icons.security,
      iconGradient: AppColors.gradientGreen,
      title: 'Safe & Secure',
      description: '30-day recovery period. We never delete photos automatically',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      _pages.length - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Skip'),
                ),
              )
            else
              const SizedBox(height: 48),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildPageIndicator(index == _currentPage),
              ),
            ),

            const SizedBox(height: 32),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _handleGetStarted
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: AppTextStyles.button.copyWith(fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.iconGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: page.iconGradient[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Future<void> _handleGetStarted() async {
    // Request photo permissions
    final permissionService = PermissionService();
    final status = await permissionService.requestPhotoPermission();

    // Mark onboarding as completed
    final storageService = StorageService();
    await storageService.init();
    await storageService.setOnboardingCompleted(true);

    if (mounted) {
      if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
        // Permission granted, go to home
        context.go('/home');
      } else {
        // Permission denied, show dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Photo Access Required'),
            content: const Text(
              'Clean Gallery needs access to your photos to function. '
              'Please grant permission in Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
                child: const Text('Skip for Now'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await permissionService.openAppSettings();
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.go('/home');
                  }
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _OnboardingPage {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.description,
  });
}
