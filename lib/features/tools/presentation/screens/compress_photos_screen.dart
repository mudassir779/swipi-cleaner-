import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../../shared/services/compression_service.dart';
import '../../../../shared/services/photo_service.dart';

/// Provider for compression state
final compressionStateProvider =
    StateNotifierProvider<CompressionStateNotifier, CompressionState>((ref) {
  return CompressionStateNotifier();
});

class CompressionState {
  final List<AssetEntity> selectedPhotos;
  final int quality;
  final bool isCompressing;
  final int processedCount;
  final int totalSavedBytes;
  final String? errorMessage;

  const CompressionState({
    this.selectedPhotos = const [],
    this.quality = 70,
    this.isCompressing = false,
    this.processedCount = 0,
    this.totalSavedBytes = 0,
    this.errorMessage,
  });

  CompressionState copyWith({
    List<AssetEntity>? selectedPhotos,
    int? quality,
    bool? isCompressing,
    int? processedCount,
    int? totalSavedBytes,
    String? errorMessage,
  }) {
    return CompressionState(
      selectedPhotos: selectedPhotos ?? this.selectedPhotos,
      quality: quality ?? this.quality,
      isCompressing: isCompressing ?? this.isCompressing,
      processedCount: processedCount ?? this.processedCount,
      totalSavedBytes: totalSavedBytes ?? this.totalSavedBytes,
      errorMessage: errorMessage,
    );
  }
}

class CompressionStateNotifier extends StateNotifier<CompressionState> {
  CompressionStateNotifier() : super(const CompressionState());

  void togglePhoto(AssetEntity photo) {
    final current = List<AssetEntity>.from(state.selectedPhotos);
    if (current.any((p) => p.id == photo.id)) {
      current.removeWhere((p) => p.id == photo.id);
    } else {
      current.add(photo);
    }
    state = state.copyWith(selectedPhotos: current);
  }

  void setQuality(int quality) {
    state = state.copyWith(quality: quality);
  }

  void startCompression() {
    state = state.copyWith(isCompressing: true, processedCount: 0, totalSavedBytes: 0);
  }

  void updateProgress(int processed, int savedBytes) {
    state = state.copyWith(
      processedCount: processed,
      totalSavedBytes: state.totalSavedBytes + savedBytes,
    );
  }

  void finishCompression() {
    state = state.copyWith(isCompressing: false);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isCompressing: false);
  }

  void reset() {
    state = const CompressionState();
  }
}

/// Photo compression screen
class CompressPhotosScreen extends ConsumerStatefulWidget {
  const CompressPhotosScreen({super.key});

  @override
  ConsumerState<CompressPhotosScreen> createState() => _CompressPhotosScreenState();
}

class _CompressPhotosScreenState extends ConsumerState<CompressPhotosScreen> {
  final PhotoService _photoService = PhotoService();
  final CompressionService _compressionService = CompressionService();
  List<AssetEntity> _allPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await _photoService.getAllPhotos(size: 200);
    setState(() {
      _allPhotos = photos;
      _isLoading = false;
    });
  }

  Future<void> _startCompression() async {
    final state = ref.read(compressionStateProvider);
    if (state.selectedPhotos.isEmpty) return;

    ref.read(compressionStateProvider.notifier).startCompression();

    int processed = 0;
    for (final photo in state.selectedPhotos) {
      final result = await _compressionService.compressAsset(
        asset: photo,
        quality: state.quality,
      );
      
      if (result != null) {
        // Save to gallery
        await _compressionService.saveToGallery(result.compressedFile);
        processed++;
        ref.read(compressionStateProvider.notifier).updateProgress(
          processed,
          result.savedBytes,
        );
      }
    }

    ref.read(compressionStateProvider.notifier).finishCompression();
    
    if (mounted) {
      _showCompletionDialog(processed, ref.read(compressionStateProvider).totalSavedBytes);
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
              '$count photos compressed',
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compressionStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Compress Photos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Quality slider section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Compression Quality',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              CompressionService.getQualityPresetName(state.quality),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Max',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: state.quality.toDouble(),
                              min: 10,
                              max: 100,
                              divisions: 9,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.divider,
                              onChanged: state.isCompressing
                                  ? null
                                  : (value) {
                                      ref
                                          .read(compressionStateProvider.notifier)
                                          .setQuality(value.toInt());
                                    },
                            ),
                          ),
                          const Text(
                            'Min',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lower quality = smaller file size',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.selectedPhotos.length} selected',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (state.selectedPhotos.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref.read(compressionStateProvider.notifier).reset();
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),

                // Photo grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _allPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = _allPhotos[index];
                      final isSelected = state.selectedPhotos.any((p) => p.id == photo.id);

                      return GestureDetector(
                        onTap: state.isCompressing
                            ? null
                            : () {
                                ref
                                    .read(compressionStateProvider.notifier)
                                    .togglePhoto(photo);
                              },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image(
                                image: AssetEntityImageProvider(
                                  photo,
                                  isOriginal: false,
                                  thumbnailSize: const ThumbnailSize(200, 200),
                                ),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
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
      bottomNavigationBar: state.selectedPhotos.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: SafeArea(
                child: state.isCompressing
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: state.processedCount / state.selectedPhotos.length,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Compressing ${state.processedCount}/${state.selectedPhotos.length}...',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _startCompression,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Compress ${state.selectedPhotos.length} Photos',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
    );
  }
}
