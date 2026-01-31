import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Grid item for displaying a photo thumbnail
class PhotoGridItem extends StatelessWidget {
  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const PhotoGridItem({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo thumbnail (with shimmer placeholder + fade-in)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.divider.withValues(alpha: 0.45),
                  highlightColor: AppColors.surface.withValues(alpha: 0.9),
                  child: Container(color: AppColors.divider),
                ),
                Image(
                  image: AssetEntityImageProvider(
                    asset,
                    isOriginal: false,
                    thumbnailSize: ThumbnailSize(240, 240),
                  ),
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
              ],
            ),
          ),

          // Video duration indicator
          if (asset.type == AssetType.video)
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
                      _formatDuration(asset.videoDuration),
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

          // Selection checkmark
          Positioned(
            top: 6,
            right: 6,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutBack,
              scale: isSelected ? 1 : 0.9,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: isSelected ? 1 : 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),

          // Subtle overlay when selected
          if (isSelected)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
