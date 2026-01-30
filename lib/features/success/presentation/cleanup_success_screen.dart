import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_bytes.dart';
import '../../../core/widgets/gradient_scaffold_background.dart';
import '../../../core/widgets/primary_gradient_button.dart';
import '../domain/models/cleanup_success_result.dart';

class CleanupSuccessScreen extends StatefulWidget {
  final CleanupSuccessResult result;

  const CleanupSuccessScreen({
    super.key,
    required this.result,
  });

  @override
  State<CleanupSuccessScreen> createState() => _CleanupSuccessScreenState();
}

class _CleanupSuccessScreenState extends State<CleanupSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final before = result.storageBeforeBytes;
    final after = result.storageAfterBytes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Success'),
      ),
      body: GradientScaffoldBackground(
        colors: const [
          Color(0xFFECFDF5), // emerald-50
          Color(0xFFFFFFFF),
          Color(0xFFF0FDF4), // green-50
        ],
        child: Stack(
          children: [
            const _ConfettiOverlay(),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final t = Curves.easeOutBack.transform(_controller.value);
                        return Transform.scale(
                          scale: t,
                          child: Container(
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF22C55E)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                  blurRadius: 50,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 70),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  AnimatedOpacity(
                    opacity: _controller.value > 0.25 ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    child: const Center(
                      child: Text(
                        'Successfully Cleaned!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: result.bytesFreed),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (rect) => const LinearGradient(
                                colors: [Color(0xFF059669), Color(0xFF16A34A)],
                              ).createShader(rect),
                              child: Text(
                                formatBytes(value),
                                style: const TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Freed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (before != null && after != null)
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            title: 'Before',
                            value: '${formatBytes(before)} used',
                            icon: Icons.cloud_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStatCard(
                            title: 'After',
                            value: '${formatBytes(after)} used',
                            icon: Icons.storage_outlined,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _VerticalStat(
                          icon: Icons.delete_outline,
                          label: 'Deleted',
                          value: '${result.itemsDeleted}',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Expanded(
                        child: _VerticalStat(
                          icon: Icons.content_copy,
                          label: 'Duplicates',
                          value: '${result.duplicatesRemoved ?? 0}',
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                      Expanded(
                        child: _VerticalStat(
                          icon: Icons.storage_rounded,
                          label: 'Freed',
                          value: formatBytes(result.bytesFreed),
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share coming soon')),
                            );
                          },
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Share'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryGradientButton(
                          colors: const [Color(0xFF059669), Color(0xFF16A34A)],
                          onPressed: () => context.go('/photos'),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _VerticalStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay();

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
    ];

    // Deterministic “random” confetti.
    for (int i = 0; i < 60; i++) {
      final seed = i * 9973;
      final x = ((seed % 1000) / 1000) * size.width;
      final speed = 0.35 + ((seed % 100) / 200);
      final y = (progress * speed) * size.height - ((seed % 500) / 500) * 200;
      final rot = (progress * 6) + ((seed % 360) / 180);

      if (y < -40 || y > size.height + 40) continue;

      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: 0.85);
      final w = 6.0 + (seed % 6);
      final h = 10.0 + (seed % 8);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), const Radius.circular(2)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
