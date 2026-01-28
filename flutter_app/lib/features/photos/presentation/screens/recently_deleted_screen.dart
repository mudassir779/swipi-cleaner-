import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/providers/recently_deleted_provider.dart';

/// Recently deleted photos screen with 30-day recovery
class RecentlyDeletedScreen extends ConsumerWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyDeleted = ref.watch(recentlyDeletedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recently Deleted'),
        actions: [
          if (recentlyDeleted.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearAllDialog(context, ref);
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: recentlyDeleted.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Recently Deleted Photos',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Deleted photos will appear here for 30 days',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Photos will be permanently deleted after 30 days',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid of deleted photos
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: recentlyDeleted.length,
                    itemBuilder: (context, index) {
                      final item = recentlyDeleted[index];
                      return _buildDeletedPhotoItem(context, ref, item);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDeletedPhotoItem(
    BuildContext context,
    WidgetRef ref,
    DeletedPhoto item,
  ) {
    return GestureDetector(
      onTap: () {
        _showPhotoOptions(context, ref, item);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image(
              image: AssetEntityImageProvider(
                item.asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(200),
              ),
              fit: BoxFit.cover,
            ),

            // Overlay with days remaining
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  '${item.daysRemaining} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, WidgetRef ref, DeletedPhoto item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.restore, color: AppColors.green),
              title: const Text('Restore Photo'),
              subtitle: Text('${item.daysRemaining} days remaining'),
              onTap: () {
                ref.read(recentlyDeletedProvider.notifier).restore(item.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo restored (feature in progress)'),
                    backgroundColor: AppColors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.red),
              title: const Text('Delete Permanently'),
              subtitle: const Text('Cannot be undone'),
              onTap: () {
                Navigator.pop(context);
                _showPermanentDeleteDialog(context, ref, item);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPermanentDeleteDialog(BuildContext context, WidgetRef ref, DeletedPhoto item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: const Text(
          'This photo will be permanently deleted and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(recentlyDeletedProvider.notifier).remove(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo permanently deleted'),
                  backgroundColor: AppColors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    final count = ref.read(recentlyDeletedProvider).length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All?'),
        content: Text(
          'Permanently delete all $count ${count == 1 ? 'photo' : 'photos'}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(recentlyDeletedProvider.notifier).clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$count ${count == 1 ? 'photo' : 'photos'} permanently deleted'),
                  backgroundColor: AppColors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
