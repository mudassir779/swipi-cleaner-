import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/permission_service.dart';
import '../../../shared/services/storage_service.dart';
import 'widgets/safe_secure_onboarding_hero.dart';
import 'widgets/smart_collections_onboarding_hero.dart';
import 'widgets/swipe_to_clean_onboarding_hero.dart';

/// Onboarding screen with feature introduction and permission request
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page 2 (Swipe to Clean) styling tokens to match v0 design.
  static const Color _amber50 = Color(0xFFFFFBEB);
  static const Color _orange50 = Color(0xFFFFF7ED);
  static const Color _gray300 = Color(0xFFD1D5DB);
  static const Color _gray400 = Color(0xFF9CA3AF);
  static const Color _gray700 = Color(0xFF374151);
  static const Color _gray800 = Color(0xFF1F2937);
  static const Color _gray900 = Color(0xFF111827);

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
      description: 'Simple swipe gestures make organizing your photos intuitive and fun',
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome,
      iconGradient: AppColors.gradientPurple,
      title: 'Smart Collections',
      description: 'Automatically organize photos by date and find duplicates instantly',
    ),
    _OnboardingPage(
      icon: Icons.security,
      iconGradient: AppColors.gradientGreen,
      title: 'Safe & Secure',
      description: 'Your photos are protected with advanced encryption technology',
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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: _currentPage == 1
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_amber50, Colors.white, _orange50],
                )
              : _currentPage == 2
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEFF6FF), Colors.white, Color(0xFFEEF2FF)],
                    )
                  : _currentPage == 3
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFECFDF5), Colors.white, Color(0xFFF0FDF4)],
                        )
                      : null,
          color: (_currentPage == 1 || _currentPage == 2 || _currentPage == 3)
              ? null
              : AppColors.background,
        ),
        child: SafeArea(
          child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: (_currentPage == 1 || _currentPage == 2 || _currentPage == 3)
                        ? _gray400
                        : AppColors.primary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
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
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildPageIndicator(index: index, isActive: index == _currentPage),
              ),
            ),

            const SizedBox(height: 32),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: _buildActionButton(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    // v0-style Swipe to Clean page
    if (index == 1) {
      return SwipeToCleanOnboardingHero(
        title: page.title,
        description: page.description,
      );
    }

    if (index == 2) {
      return SmartCollectionsOnboardingHero(
        title: page.title,
        description: page.description,
      );
    }

    if (index == 3) {
      return SafeSecureOnboardingHero(
        title: page.title,
        description: page.description,
      );
    }

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

  Widget _buildPageIndicator({required int index, required bool isActive}) {
    // v0-style indicator for pages 2-4: dark pill for active step, grey dots elsewhere.
    if (_currentPage == 1 || _currentPage == 2 || _currentPage == 3) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 32 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? null : _gray300,
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [_gray700, _gray900],
                )
              : null,
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

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

  Widget _buildActionButton() {
    final onPressed = _currentPage == _pages.length - 1
        ? _handleGetStarted
        : () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          };

    final label = _currentPage == _pages.length - 1 ? 'Get Started' : 'Next';

    // v0-style dark gradient button for pages 2-4
    if (_currentPage == 1 || _currentPage == 2 || _currentPage == 3) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_gray800, _gray900],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.button.copyWith(fontSize: 18),
      ),
    );
  }

  Future<void> _handleGetStarted() async {
    // Request photo permissions
    final permissionService = PermissionService();
    final status = await permissionService.requestPhotoPermission();

    // Check if widget is still mounted before continuing
    if (!mounted) return;

    // Mark onboarding as completed
    final storageService = StorageService();
    await storageService.init();
    await storageService.setOnboardingCompleted(true);

    if (mounted) {
      if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
        // Permission granted, go to home
        context.go('/photos');
      } else {
        // Permission denied, show dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Photo Access Required'),
            content: const Text(
              'Swipple needs access to your photos to function. '
              'Please grant permission in Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/photos');
                },
                child: const Text('Skip for Now'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await openAppSettings();
                  } catch (e) {
                    // openAppSettings may not be available in some versions
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.go('/photos');
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
