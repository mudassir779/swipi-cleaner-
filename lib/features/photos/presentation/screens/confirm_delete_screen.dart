import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../../shared/services/photo_service.dart';
import '../../../home/domain/providers/home_provider.dart';
import '../../../success/domain/models/cleanup_success_result.dart';
import '../../domain/providers/delete_queue_provider.dart';
import '../../domain/providers/delete_queue_items_provider.dart';
import '../../domain/providers/photo_provider.dart';
import '../../domain/providers/month_photos_provider.dart';

/// Confirmation screen before permanently deleting photos
class ConfirmDeleteScreen extends ConsumerStatefulWidget {
  const ConfirmDeleteScreen({super.key});

  @override
  ConsumerState<ConfirmDeleteScreen> createState() => _ConfirmDeleteScreenState();
}

class _ConfirmDeleteScreenState extends ConsumerState<ConfirmDeleteScreen> {
  bool _isDeleting = false;
  bool _confirmArmed = false;
  _DeleteFilter _filter = _DeleteFilter.all;

  @override
  Widget build(BuildContext context) {
    final deleteQueue = ref.watch(deleteQueueProvider);
    final candidatesAsync = ref.watch(deleteQueueItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Deletion'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: candidatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: AppTextStyles.body),
        ),
        data: (candidates) {
          if (deleteQueue.isEmpty || candidates.isEmpty) {
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
                    'No Items Selected',
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

          final photoService = PhotoService();

          final filtered = candidates.where((c) {
            switch (_filter) {
              case _DeleteFilter.all:
                return true;
              case _DeleteFilter.photos:
                return c.asset.type == AssetType.image;
              case _DeleteFilter.videos:
                return c.asset.type == AssetType.video;
              case _DeleteFilter.screenshots:
                return c.asset.type == AssetType.image && photoService.isScreenshot(c.asset);
            }
          }).toList();

          final totalSize = filtered.fold<int>(0, (sum, c) => sum + c.fileSizeBytes);

          return Column(
            children: [
              // Summary card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 42,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You\'re about to delete:',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatBytes(totalSize)} will be freed',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This action cannot be undone',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: _isDeleting
                              ? null
                              : () {
                                  if (deleteQueue.length == candidates.length) {
                                    ref.read(deleteQueueProvider.notifier).deselectAll();
                                  } else {
                                    ref.read(deleteQueueProvider.notifier).selectAll(
                                          candidates.map((c) => c.id).toList(),
                                        );
                                  }
                                },
                          child: Text(
                            deleteQueue.length == candidates.length ? 'Deselect All' : 'Select All',
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _isDeleting
                              ? null
                              : () {
                                  ref.read(deleteQueueProvider.notifier).clear();
                                  context.pop();
                                },
                          child: const Text('Undo Selection'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _filter == _DeleteFilter.all,
                            onTap: _isDeleting ? null : () => setState(() => _filter = _DeleteFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Photos',
                            selected: _filter == _DeleteFilter.photos,
                            onTap: _isDeleting ? null : () => setState(() => _filter = _DeleteFilter.photos),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Videos',
                            selected: _filter == _DeleteFilter.videos,
                            onTap: _isDeleting ? null : () => setState(() => _filter = _DeleteFilter.videos),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Screenshots',
                            selected: _filter == _DeleteFilter.screenshots,
                            onTap: _isDeleting ? null : () => setState(() => _filter = _DeleteFilter.screenshots),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isSelected = deleteQueue.contains(item.id);
                    return GestureDetector(
                      onTap: _isDeleting
                          ? null
                          : () {
                              ref.read(deleteQueueProvider.notifier).toggle(item.id);
                            },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image(
                              image: AssetEntityImageProvider(
                                item.asset,
                                isOriginal: false,
                                thumbnailSize: ThumbnailSize(220, 220),
                              ),
                              fit: BoxFit.cover,
                            ),
                            // Red X badge
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                            // Checkbox (for deselect)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Icon(
                                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            if (!isSelected)
                              Container(color: Colors.black.withValues(alpha: 0.35)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isDeleting) ...[
                        const LinearProgressIndicator(minHeight: 4),
                        const SizedBox(height: 10),
                        Text(
                          'Deleting ${filtered.length} items...',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isDeleting
                              ? null
                              : () async {
                                  if (!_confirmArmed) {
                                    setState(() => _confirmArmed = true);
                                    Future<void>.delayed(const Duration(seconds: 3), () {
                                      if (!mounted) return;
                                      setState(() => _confirmArmed = false);
                                    });
                                    return;
                                  }
                                  await _handleDelete(filtered, totalSize);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              : Text(
                                  _confirmArmed ? 'Tap again to confirm' : 'Permanently Delete',
                                  style: AppTextStyles.button.copyWith(fontSize: 16),
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

  Future<void> _handleDelete(List<dynamic> candidates, int bytesFreed) async {
    setState(() => _isDeleting = true);

    try {
      final photoService = PhotoService();
      final before = await ref.read(homeStatsProvider.future);
      final assets = candidates.map((p) => p.asset as AssetEntity).toList();

      // Delete from device (goes to iOS/Android built-in Recently Deleted)
      await photoService.deleteAssets(assets);

      // Clear delete queue
      ref.read(deleteQueueProvider.notifier).clear();

      // Invalidate all photo-related providers to refresh the UI
      ref.invalidate(filteredPhotosProvider);
      ref.invalidate(photosProvider);
      ref.invalidate(photoCountProvider);
      ref.invalidate(monthPhotosProvider);
      ref.invalidate(recentPhotosProvider);
      ref.invalidate(randomPhotosProvider);
      ref.invalidate(todayPhotosProvider);
      ref.invalidate(deleteQueueItemsProvider);
      ref.invalidate(homeStatsProvider);

      if (mounted) {
        final afterUsed = (before.storageUsed - bytesFreed).clamp(0, before.storageUsed);
        context.go(
          '/success',
          extra: CleanupSuccessResult(
            itemsDeleted: assets.length,
            bytesFreed: bytesFreed,
            storageBeforeBytes: before.storageUsed,
            storageAfterBytes: afterUsed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete photos. Please try again.'),
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
}

enum _DeleteFilter { all, photos, videos, screenshots }

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.textPrimary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
