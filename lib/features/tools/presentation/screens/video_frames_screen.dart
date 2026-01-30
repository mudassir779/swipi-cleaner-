import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/video_frames_service.dart';
import '../../../../shared/services/photo_service.dart';

/// Provider for video frames state
final videoFramesStateProvider =
    StateNotifierProvider<VideoFramesStateNotifier, VideoFramesState>((ref) {
  return VideoFramesStateNotifier();
});

class VideoFramesState {
  final AssetEntity? selectedVideo;
  final int intervalSeconds;
  final bool isExtracting;
  final List<File> extractedFrames;
  final bool isSaving;
  final String? errorMessage;

  const VideoFramesState({
    this.selectedVideo,
    this.intervalSeconds = 1,
    this.isExtracting = false,
    this.extractedFrames = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  VideoFramesState copyWith({
    AssetEntity? selectedVideo,
    int? intervalSeconds,
    bool? isExtracting,
    List<File>? extractedFrames,
    bool? isSaving,
    String? errorMessage,
  }) {
    return VideoFramesState(
      selectedVideo: selectedVideo ?? this.selectedVideo,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      isExtracting: isExtracting ?? this.isExtracting,
      extractedFrames: extractedFrames ?? this.extractedFrames,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class VideoFramesStateNotifier extends StateNotifier<VideoFramesState> {
  VideoFramesStateNotifier() : super(const VideoFramesState());

  void selectVideo(AssetEntity video) {
    state = state.copyWith(selectedVideo: video, extractedFrames: []);
  }

  void setInterval(int seconds) {
    state = state.copyWith(intervalSeconds: seconds);
  }

  void setExtracting(bool value) {
    state = state.copyWith(isExtracting: value);
  }

  void setExtractedFrames(List<File> frames) {
    state = state.copyWith(extractedFrames: frames, isExtracting: false);
  }

  void setSaving(bool value) {
    state = state.copyWith(isSaving: value);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isExtracting: false);
  }

  void reset() {
    state = const VideoFramesState();
  }
}

/// Video frames extraction screen
class VideoFramesScreen extends ConsumerStatefulWidget {
  const VideoFramesScreen({super.key});

  @override
  ConsumerState<VideoFramesScreen> createState() => _VideoFramesScreenState();
}

class _VideoFramesScreenState extends ConsumerState<VideoFramesScreen> {
  final PhotoService _photoService = PhotoService();
  final VideoFramesService _videoFramesService = VideoFramesService();
  List<AssetEntity> _allVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await _photoService.getAllPhotos(
      size: 100,
      type: RequestType.video,
    );
    setState(() {
      _allVideos = videos;
      _isLoading = false;
    });
  }

  Future<void> _extractFrames() async {
    final state = ref.read(videoFramesStateProvider);
    if (state.selectedVideo == null) return;

    ref.read(videoFramesStateProvider.notifier).setExtracting(true);

    final frames = await _videoFramesService.extractFrames(
      video: state.selectedVideo!,
      intervalSeconds: state.intervalSeconds,
    );

    ref.read(videoFramesStateProvider.notifier).setExtractedFrames(frames);
  }

  Future<void> _saveToGallery() async {
    final state = ref.read(videoFramesStateProvider);
    if (state.extractedFrames.isEmpty) return;

    ref.read(videoFramesStateProvider.notifier).setSaving(true);

    final savedAssets = await _videoFramesService.saveFramesToGallery(
      state.extractedFrames,
    );

    ref.read(videoFramesStateProvider.notifier).setSaving(false);

    if (mounted) {
      _showSuccessDialog(savedAssets.length);
    }
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '🎉 Frames Saved!',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '$count frames saved to gallery',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoFramesStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Extract Video Frames',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(videoFramesStateProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.selectedVideo == null
              ? _buildVideoSelection()
              : _buildFrameExtractor(state),
      bottomNavigationBar: _buildBottomBar(state),
    );
  }

  Widget _buildVideoSelection() {
    if (_allVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Videos Found',
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Record some videos to extract frames',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select a video',
            style: AppTextStyles.title.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _allVideos.length,
            itemBuilder: (context, index) {
              final video = _allVideos[index];

              return GestureDetector(
                onTap: () {
                  ref.read(videoFramesStateProvider.notifier).selectVideo(video);
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: AssetEntityImageProvider(
                          video,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize(400, 400),
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(video.videoDuration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFrameExtractor(VideoFramesState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected video preview
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surface,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image(
                    image: AssetEntityImageProvider(
                      state.selectedVideo!,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize(800, 800),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      ref.read(videoFramesStateProvider.notifier).reset();
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDuration(state.selectedVideo!.videoDuration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interval selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Frame Interval',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildIntervalChip(1, state),
                    const SizedBox(width: 8),
                    _buildIntervalChip(2, state),
                    const SizedBox(width: 8),
                    _buildIntervalChip(5, state),
                    const SizedBox(width: 8),
                    _buildIntervalChip(10, state),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Extract a frame every ${state.intervalSeconds} second${state.intervalSeconds > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Extracted frames
          if (state.extractedFrames.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.extractedFrames.length} Frames Extracted',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.extractedFrames.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        state.extractedFrames[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildIntervalChip(int seconds, VideoFramesState state) {
    final isSelected = state.intervalSeconds == seconds;

    return GestureDetector(
      onTap: state.isExtracting
          ? null
          : () {
              ref.read(videoFramesStateProvider.notifier).setInterval(seconds);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          '${seconds}s',
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget? _buildBottomBar(VideoFramesState state) {
    if (state.selectedVideo == null) return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        child: state.isExtracting
            ? const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Extracting frames...',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              )
            : state.extractedFrames.isEmpty
                ? ElevatedButton.icon(
                    onPressed: _extractFrames,
                    icon: const Icon(Icons.photo_library),
                    label: const Text(
                      'Extract Frames',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : state.isSaving
                    ? const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Saving to gallery...',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _extractFrames,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Re-extract',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _saveToGallery,
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Save to Gallery',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
