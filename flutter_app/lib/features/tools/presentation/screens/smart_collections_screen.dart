import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Smart collections screen showing auto-categorized photos
class SmartCollectionsScreen extends ConsumerWidget {
  const SmartCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = [
      _CollectionItem(
        title: 'Large Files',
        subtitle: 'Photos over 10MB',
        icon: Icons.file_present,
        gradient: AppColors.gradientOrange,
        count: 0,
      ),
      _CollectionItem(
        title: 'Old Photos',
        subtitle: 'More than 1 year old',
        icon: Icons.history,
        gradient: AppColors.gradientPurple,
        count: 0,
      ),
      _CollectionItem(
        title: 'Screenshots',
        subtitle: 'Screen captures',
        icon: Icons.screenshot,
        gradient: AppColors.gradientBlue,
        count: 0,
      ),
      _CollectionItem(
        title: 'Similar Photos',
        subtitle: 'Near-duplicate images',
        icon: Icons.photo_library,
        gradient: AppColors.gradientTeal,
        count: 0,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Smart Collections'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'AUTO-CATEGORIZED PHOTOS',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 16),
          ...collections.map((collection) => _buildCollectionCard(
                context,
                collection,
              )),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, _CollectionItem collection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${collection.title} coming soon')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: collection.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  collection.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.subtitle,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    collection.count.toString(),
                    style: AppTextStyles.statValue.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'photos',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
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

class _CollectionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final int count;

  _CollectionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.count,
  });
}
