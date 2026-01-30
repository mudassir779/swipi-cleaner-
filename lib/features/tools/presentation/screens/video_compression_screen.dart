import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../../shared/services/video_compression_service.dart';
import '../../../../shared/services/photo_service.dart';

/// Provider for video compression state
final videoCompressionStateProvider =
    StateNotifierProvider<VideoCompressionStateNotifier, VideoCompressionState>((ref) {
  return VideoCompressionStateNotifier();
});

class VideoCompressionState {
  final List<AssetEntity> selectedVideos;
  final AppVideoQuality quality;
  final bool isCompressing;
  final int processedCount;
  final int totalSavedBytes;
  final double currentProgress;

  const VideoCompressionState({
    this.selectedVideos = const [],
    this.quality = AppVideoQuality.medium,
    this.isCompressing = false,
    this.processedCount = 0,
    this.totalSavedBytes = 0,
    this.currentProgress = 0.0,
  });

  VideoCompressionState copyWith({
    List<AssetEntity>? selectedVideos,
    AppVideoQuality? quality,
    bool? isCompressing,
    int? processedCount,
    int? totalSavedBytes,
    double? currentProgress,
  }) {
    return VideoCompressionState(
      selectedVideos: selectedVideos ?? this.selectedVideos,
      quality: quality ?? this.quality,
      isCompressing: isCompressing ?? this.isCompressing,
      processedCount: processedCount ?? this.processedCount,
      totalSavedBytes: totalSavedBytes ?? this.totalSavedBytes,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}

class VideoCompressionStateNotifier extends StateNotifier<VideoCompressionState> {
  VideoCompressionStateNotifier() : super(const VideoCompressionState());

  void toggleVideo(AssetEntity video) {
    if (state.isCompressing) return;
    
    final current = List<AssetEntity>.from(state.selectedVideos);
    // Allow multi-select, but maybe warn if too many? For now unlimited.
    if (current.any((p) => p.id == video.id)) {
      current.removeWhere((p) => p.id == video.id);
    } else {
      current.add(video);
    }
    state = state.copyWith(selectedVideos: current);
  }

  void setQuality(AppVideoQuality quality) {
    if (state.isCompressing) return;
    state = state.copyWith(quality: quality);
  }

  void startCompression() {
    state = state.copyWith(
      isCompressing: true, 
      processedCount: 0, 
      totalSavedBytes: 0,
      currentProgress: 0.0,
    );
  }

  void updateProgress(double progress) {
    state = state.copyWith(currentProgress: progress);
  }

  void finishOneVideo(int savedBytes) {
    state = state.copyWith(
      processedCount: state.processedCount + 1,
      totalSavedBytes: state.totalSavedBytes + savedBytes,
      currentProgress: 0.0, // Reset for next file
    );
  }

  void finishAll() {
    state = state.copyWith(isCompressing: false, currentProgress: 1.0);
  }

  void reset() {
    state = const VideoCompressionState();
  }
}

class VideoCompressionScreen extends ConsumerStatefulWidget {
  const VideoCompressionScreen({super.key});

  @override
  ConsumerState<VideoCompressionScreen> createState() => _VideoCompressionScreenState();
}

class _VideoCompressionScreenState extends ConsumerState<VideoCompressionScreen> {
  final PhotoService _photoService = PhotoService();
  final VideoCompressionService _compressionService = VideoCompressionService();
  List<AssetEntity> _allVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    // Load videos instead of images
    final videos = await _photoService.getAllPhotos(
      size: 200, 
      type: RequestType.video,
    );
    setState(() {
      _allVideos = videos;
      _isLoading = false;
    });
  }

  Future<void> _startCompression() async {
    final state = ref.read(videoCompressionStateProvider);
    if (state.selectedVideos.isEmpty) return;

    ref.read(videoCompressionStateProvider.notifier).startCompression();

    // Listen to service progress stream
    final subscription = _compressionService.progressStream.listen((progress) {
      ref.read(videoCompressionStateProvider.notifier).updateProgress(progress);
    });

    try {
      for (final videoAsset in state.selectedVideos) {
        final file = await videoAsset.file;
        if (file == null) continue;

        final originalSize = await file.length();
        
        final compressedFile = await _compressionService.compressVideo(
          file, 
          state.quality,
        );

        if (compressedFile != null) {
          final compressedSize = await compressedFile.length();
          final savedBytes = originalSize - compressedSize;
          
          // Save to gallery
          await PhotoManager.editor.saveVideo(
            compressedFile, 
            title: 'compressed_${videoAsset.title}',
          );
          
          ref.read(videoCompressionStateProvider.notifier).finishOneVideo(
            savedBytes > 0 ? savedBytes : 0
          );
        }
      }
    } finally {
      subscription.cancel();
      ref.read(videoCompressionStateProvider.notifier).finishAll();
      
      if (mounted) {
        _showCompletionDialog(
          ref.read(videoCompressionStateProvider).processedCount,
          ref.read(videoCompressionStateProvider).totalSavedBytes,
        );
      }
    }
  }

  void _showCompletionDialog(int count, int savedBytes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '🎉 Compression Complete!',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count videos compressed',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatBytes(savedBytes)} saved',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ref.read(videoCompressionStateProvider.notifier).reset(); // Reset selection
            },
            child: const Text('New Compression'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to tools
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoCompressionStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compress Videos', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Quality Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quality Preset',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildQualityChip(AppVideoQuality.low, 'Low (480p)', state),
                          const SizedBox(width: 8),
                          _buildQualityChip(AppVideoQuality.medium, 'Medium (720p)', state),
                          const SizedBox(width: 8),
                          _buildQualityChip(AppVideoQuality.high, 'High (Original)', state),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Selection Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.selectedVideos.length} videos selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (state.selectedVideos.isNotEmpty && !state.isCompressing)
                        TextButton(
                          onPressed: () => ref.read(videoCompressionStateProvider.notifier).reset(),
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),

                // Video Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _allVideos.length,
                    itemBuilder: (context, index) {
                      final video = _allVideos[index];
                      final isSelected = state.selectedVideos.any((v) => v.id == video.id);

                      return GestureDetector(
                        onTap: state.isCompressing ? null : () {
                          ref.read(videoCompressionStateProvider.notifier).toggleVideo(video);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AssetEntityImage(
                                video,
                                isOriginal: false,
                                thumbnailSize: const ThumbnailSize(200, 200),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Duration badge
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _formatDuration(video.duration),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                child: const Center(
                                  child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: state.selectedVideos.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SafeArea(
                child: state.isCompressing
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: state.currentProgress,
                            backgroundColor: AppColors.divider,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Compressing ${state.processedCount + 1}/${state.selectedVideos.length}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _startCompression,
                        child: Text(
                          'Compress ${state.selectedVideos.length} Videos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildQualityChip(AppVideoQuality quality, String label, VideoCompressionState state) {
    final isSelected = state.quality == quality;
    return Expanded(
      child: GestureDetector(
        onTap: state.isCompressing ? null : () {
          ref.read(videoCompressionStateProvider.notifier).setQuality(quality);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
