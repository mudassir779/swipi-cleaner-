import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_bytes.dart';
import '../../../core/widgets/primary_gradient_button.dart';
import '../domain/providers/storage_overview_provider.dart';
import 'widgets/animated_donut_chart.dart';

class StorageOverviewScreen extends ConsumerWidget {
  const StorageOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(storageOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Storage Stats'),
      ),
      body: SafeArea(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load storage stats.\n$e',
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (overview) {
            final used = overview.estimatedUsedBytes;
            final cap = overview.estimatedCapacityBytes;
            final pct = cap == 0 ? 0.0 : (used / cap).clamp(0.0, 1.0);

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF5F3FF), Color(0xFFF3E8FF)],
                        ),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          AnimatedDonutChart(
                            progress: pct,
                            gradient: const [Color(0xFF9C27B0), Color(0xFF7C4DFF), Color(0xFF9C27B0)],
                            centerValue: '${(pct * 100).round()}%',
                            centerLabel: 'used',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${formatBytes(used)} of ${formatBytes(cap)} used',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            overview.estimatedFreeableBytes == 0
                                ? 'No quick wins detected yet'
                                : '${formatBytes(overview.estimatedFreeableBytes)} can likely be freed',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...overview.categories.map((c) {
                      final frac = used == 0 ? 0.0 : (c.bytes / used).clamp(0.0, 1.0);
                      return _CategoryRow(
                        icon: c.icon,
                        iconColor: c.color,
                        name: c.name,
                        sizeLabel: formatBytes(c.bytes),
                        fraction: frac,
                        barGradient: [c.color.withValues(alpha: 0.9), c.color.withValues(alpha: 0.55)],
                      );
                    }),
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    top: false,
                    child: PrimaryGradientButton(
                      colors: const [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                      onPressed: () => context.go('/photos'),
                      child: const Text(
                        'Free Up Space',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String sizeLabel;
  final double fraction;
  final List<Color> barGradient;

  const _CategoryRow({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.sizeLabel,
    required this.fraction,
    required this.barGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                sizeLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: AppColors.divider.withValues(alpha: 0.7),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: barGradient),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

