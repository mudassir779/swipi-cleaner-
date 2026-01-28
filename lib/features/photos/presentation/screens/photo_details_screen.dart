import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/providers/delete_queue_provider.dart';

/// Full-screen photo details with zoom and metadata
class PhotoDetailsScreen extends ConsumerStatefulWidget {
  final AssetEntity asset;
  final String photoId;

  const PhotoDetailsScreen({
    super.key,
    required this.asset,
    required this.photoId,
  });

  @override
  ConsumerState<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends ConsumerState<PhotoDetailsScreen> {
  bool _showMetadata = false;

  @override
  Widget build(BuildContext context) {
    final deleteQueue = ref.watch(deleteQueueProvider);
    final isInQueue = deleteQueue.contains(widget.photoId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo with zoom
          PhotoView(
            imageProvider: AssetEntityImageProvider(
              widget.asset,
              isOriginal: true,
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _showMetadata ? Icons.info : Icons.info_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _showMetadata = !_showMetadata);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Metadata overlay
          if (_showMetadata)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.asset.title != null) ...[
                        Text(
                          widget.asset.title!,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildMetadataRow(
                        Icons.calendar_today,
                        'Date',
                        _formatDate(widget.asset.createDateTime),
                      ),
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        Icons.photo_size_select_actual,
                        'Dimensions',
                        '${widget.asset.width} × ${widget.asset.height}',
                      ),
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        Icons.storage,
                        'Type',
                        widget.asset.type == AssetType.video ? 'Video' : 'Photo',
                      ),
                      if (widget.asset.type == AssetType.video) ...[
                        const SizedBox(height: 8),
                        _buildMetadataRow(
                          Icons.timer,
                          'Duration',
                          _formatDuration(widget.asset.videoDuration),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Bottom action bar
          if (!_showMetadata)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: isInQueue ? Icons.check_circle : Icons.delete_outline,
                        label: isInQueue ? 'Selected' : 'Delete',
                        color: isInQueue ? AppColors.green : AppColors.red,
                        onPressed: () {
                          ref.read(deleteQueueProvider.notifier).toggle(widget.photoId);
                          final newState = ref.read(deleteQueueProvider).contains(widget.photoId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newState ? 'Added to delete queue' : 'Removed from delete queue',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.body.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
