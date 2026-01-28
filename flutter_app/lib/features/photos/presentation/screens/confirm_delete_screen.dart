import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/photo_service.dart';
import '../../domain/providers/delete_queue_provider.dart';
import '../../domain/providers/photo_provider.dart';

/// Confirmation screen before permanently deleting photos
class ConfirmDeleteScreen extends ConsumerStatefulWidget {
  const ConfirmDeleteScreen({super.key});

  @override
  ConsumerState<ConfirmDeleteScreen> createState() => _ConfirmDeleteScreenState();
}

class _ConfirmDeleteScreenState extends ConsumerState<ConfirmDeleteScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final deleteQueue = ref.watch(deleteQueueProvider);
    final photosAsync = ref.watch(filteredPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Deletion'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: AppTextStyles.body),
        ),
        data: (allPhotos) {
          final photosToDelete = allPhotos.where((p) => deleteQueue.contains(p.id)).toList();

          if (photosToDelete.isEmpty) {
            return Center(
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
                    'No Photos Selected',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          // Calculate total size
          int totalSize = 0;
          for (final photo in photosToDelete) {
            totalSize += photo.fileSize ?? 0;
          }

          return Column(
            children: [
              // Summary card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.gradientRed,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Delete ${photosToDelete.length} ${photosToDelete.length == 1 ? 'Photo' : 'Photos'}?',
                      style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will free up ${_formatBytes(totalSize)}',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Photos will be moved to Recently Deleted',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Photo grid preview
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photosToDelete.length,
                  itemBuilder: (context, index) {
                    final photo = photosToDelete[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image(
                            image: AssetEntityImageProvider(
                              photo.asset,
                              isOriginal: false,
                              thumbnailSize: ThumbnailSize(200, 200),
                            ),
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: AppColors.red.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isDeleting ? null : () => _handleDelete(photosToDelete),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isDeleting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Delete ${photosToDelete.length} ${photosToDelete.length == 1 ? 'Photo' : 'Photos'}',
                                      style: AppTextStyles.button.copyWith(fontSize: 18),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isDeleting ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleDelete(List<dynamic> photosToDelete) async {
    setState(() => _isDeleting = true);

    try {
      final photoService = PhotoService();
      final assets = photosToDelete.map((p) => p.asset as AssetEntity).toList();

      // Delete from photo library
      await photoService.deleteAssets(assets);

      // Clear delete queue
      ref.read(deleteQueueProvider.notifier).clear();

      // Refresh photo list
      ref.invalidate(filteredPhotosProvider);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${photosToDelete.length} ${photosToDelete.length == 1 ? 'photo' : 'photos'} deleted'),
            backgroundColor: AppColors.green,
          ),
        );

        // Navigate to success screen or back
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting photos: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
  }
}
