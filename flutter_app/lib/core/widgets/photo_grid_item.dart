import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../theme/app_colors.dart';

/// Grid item for displaying a photo thumbnail with entrance animation
class PhotoGridItem extends StatefulWidget {
  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int index;

  const PhotoGridItem({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    this.index = 0,
  });

  @override
  State<PhotoGridItem> createState() => _PhotoGridItemState();
}

class _PhotoGridItemState extends State<PhotoGridItem> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Staggered entrance animation
    final delay = (widget.index * 20).clamp(0, 200); // Max 200ms delay
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _isVisible ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo thumbnail
                Image(
                  image: AssetEntityImageProvider(
                    widget.asset,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize(200, 200),
                  ),
                  fit: BoxFit.cover,
                ),

                // Video duration indicator
                if (widget.asset.type == AssetType.video)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatDuration(widget.asset.videoDuration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Selection overlay
                if (widget.isSelected)
                  Container(
                    color: AppColors.red.withValues(alpha: 0.4),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
