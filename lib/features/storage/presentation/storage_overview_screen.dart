import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        title: const Text('Media Storage'),
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
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          AnimatedDonutChart(
                            progress: pct,
                            gradient: AppColors.gradientPrimary,
                            centerValue: formatBytes(used),
                            centerLabel: 'media',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total media storage: ${formatBytes(used)}',
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
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.primary.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Wins',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _QuickWinRow(
                            icon: Icons.photo_library_outlined,
                            text: 'Remove duplicates',
                            subtext: overview.estimatedFreeableBytes == 0
                                ? 'Run a scan to estimate savings'
                                : 'Free ~${formatBytes(overview.estimatedFreeableBytes)}',
                          ),
                          const SizedBox(height: 10),
                          const _QuickWinRow(
                            icon: Icons.image_outlined,
                            text: 'Delete old screenshots',
                            subtext: 'Tap Categories to review',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    top: false,
                    child: PrimaryGradientButton(
                      colors: AppColors.gradientPrimary,
                      onPressed: () {
                        // Drive users into the cleanup flows.
                        Navigator.of(context).maybePop();
                      },
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

class _QuickWinRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;

  const _QuickWinRow({
    required this.icon,
    required this.text,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }
}

