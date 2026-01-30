import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gradient_scaffold_background.dart';
import '../../../core/widgets/primary_gradient_button.dart';
import '../../../core/widgets/stagger_in.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  _Plan _selected = _Plan.yearly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Upgrade to Premium',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: GradientScaffoldBackground(
        colors: const [
          Color(0xFFFFFBEB),
          Color(0xFFF5F3FF),
          Color(0xFFFDF2F8),
        ],
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ).createShader(rect),
                    child: const Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Premium Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ..._features.asMap().entries.map((e) {
                return StaggerIn(
                  delay: Duration(milliseconds: 40 + (e.key * 50)),
                  child: _FeatureRow(
                    icon: e.value.icon,
                    title: e.value.title,
                    description: e.value.description,
                  ),
                );
              }),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _PriceCard(
                      title: 'Monthly',
                      price: r'$4.99',
                      subtitle: '/month',
                      selected: _selected == _Plan.monthly,
                      badge: null,
                      accentGradient: const [Colors.white, Colors.white],
                      onTap: () => setState(() => _selected = _Plan.monthly),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PriceCard(
                      title: 'Yearly',
                      price: r'$39.99',
                      subtitle: '/year',
                      selected: _selected == _Plan.yearly,
                      badge: 'BEST VALUE',
                      accentGradient: const [Color(0xFFF59E0B), Color(0xFF7C3AED)],
                      savings: 'Save 33%',
                      onTap: () => setState(() => _selected = _Plan.yearly),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Pill(text: '⭐ 4.9/5 from 10K+ users'),
                  _Pill(text: 'Cancel anytime'),
                  _Pill(text: 'Money-back guarantee'),
                ],
              ),

              const SizedBox(height: 18),

              PrimaryGradientButton(
                colors: const [Color(0xFF7C3AED), Color(0xFFEC4899)],
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchases not wired yet (UI only).')),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Start Free Trial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selected == _Plan.yearly ? '7 days free, then \$39.99/year' : '7 days free, then \$4.99/month',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restore purchases coming soon')),
                      );
                    },
                    child: const Text('Restore Purchases'),
                  ),
                  const SizedBox(width: 6),
                  const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms & Privacy coming soon')),
                      );
                    },
                    child: const Text('Terms & Privacy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Plan { monthly, yearly }

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  const _Feature({required this.icon, required this.title, required this.description});
}

const _features = <_Feature>[
  _Feature(icon: Icons.all_inclusive_rounded, title: 'Unlimited Scans', description: 'Scan your entire library anytime'),
  _Feature(icon: Icons.auto_awesome_rounded, title: 'Advanced AI Sorting', description: 'Smart organization with AI'),
  _Feature(icon: Icons.cloud_rounded, title: 'Cloud Backup', description: 'Secure backup of all photos'),
  _Feature(icon: Icons.headset_mic_rounded, title: 'Priority Support', description: 'Get help within 24 hours'),
  _Feature(icon: Icons.visibility_off_rounded, title: 'No Ads', description: 'Clean, ad-free experience'),
  _Feature(icon: Icons.query_stats_rounded, title: 'Advanced Analytics', description: 'Detailed storage insights'),
];

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF22C55E)),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool selected;
  final String? badge;
  final String? savings;
  final List<Color> accentGradient;
  final VoidCallback onTap;

  const _PriceCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.selected,
    required this.badge,
    required this.accentGradient,
    required this.onTap,
    this.savings,
  });

  @override
  Widget build(BuildContext context) {
    final bg = badge == null ? Colors.white : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            gradient: badge == null ? null : LinearGradient(colors: accentGradient),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? const Color(0xFF7C3AED) : AppColors.divider,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: badge == null ? AppColors.textPrimary : Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: badge == null ? const Color(0xFF22C55E) : Colors.white),
                ],
              ),
              if (badge != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                price,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: badge == null ? AppColors.textPrimary : Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: badge == null ? AppColors.textSecondary : Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (savings != null) ...[
                const SizedBox(height: 8),
                Text(
                  savings!,
                  style: TextStyle(
                    color: badge == null ? const Color(0xFF22C55E) : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

