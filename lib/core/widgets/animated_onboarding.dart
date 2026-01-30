import 'package:flutter/material.dart';

/// Animated illustration for onboarding pages
/// Uses custom animations instead of external dependencies
class AnimatedOnboardingIcon extends StatefulWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final double size;
  
  const AnimatedOnboardingIcon({
    super.key,
    required this.icon,
    required this.gradientColors,
    this.size = 120,
  });

  @override
  State<AnimatedOnboardingIcon> createState() => _AnimatedOnboardingIconState();
}

class _AnimatedOnboardingIconState extends State<AnimatedOnboardingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Container(
              width: widget.size * 1.4,
              height: widget.size * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.gradientColors[0].withValues(alpha: _pulseAnimation.value * 0.3),
              ),
            ),
            // Inner pulse ring
            Container(
              width: widget.size * 1.2,
              height: widget.size * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.gradientColors[0].withValues(alpha: _pulseAnimation.value * 0.5),
              ),
            ),
            // Main icon container
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors[0].withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Floating particles animation for background
class FloatingParticles extends StatefulWidget {
  final Color color;
  final int particleCount;
  
  const FloatingParticles({
    super.key,
    this.color = Colors.white,
    this.particleCount = 20,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _particles = List.generate(widget.particleCount, (index) {
      return _Particle(
        x: (index * 0.05) % 1.0,
        y: (index * 0.07) % 1.0,
        size: 2.0 + (index % 3) * 2,
        speed: 0.1 + (index % 5) * 0.05,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            color: widget.color,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = (particle.x + progress * particle.speed) % 1.0 * size.width;
      final y = (particle.y + progress * particle.speed * 0.5) % 1.0 * size.height;
      
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Progress bar for onboarding
class OnboardingProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final Color inactiveColor;
  
  const OnboardingProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor = const Color(0xFFFF6B6B),
    this.inactiveColor = const Color(0xFFE5E7EB),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalPages, (index) {
          final isActive = index <= currentPage;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < totalPages - 1 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
