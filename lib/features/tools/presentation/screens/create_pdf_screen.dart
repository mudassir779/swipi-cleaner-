import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/pdf_service.dart';
import '../../../../shared/services/photo_service.dart';

/// Provider for PDF creation state
final pdfStateProvider =
    StateNotifierProvider<PdfStateNotifier, PdfState>((ref) {
  return PdfStateNotifier();
});

class PdfState {
  final List<AssetEntity> selectedPhotos;
  final bool isCreating;
  final String? createdPdfPath;
  final String? errorMessage;

  const PdfState({
    this.selectedPhotos = const [],
    this.isCreating = false,
    this.createdPdfPath,
    this.errorMessage,
  });

  PdfState copyWith({
    List<AssetEntity>? selectedPhotos,
    bool? isCreating,
    String? createdPdfPath,
    String? errorMessage,
  }) {
    return PdfState(
      selectedPhotos: selectedPhotos ?? this.selectedPhotos,
      isCreating: isCreating ?? this.isCreating,
      createdPdfPath: createdPdfPath,
      errorMessage: errorMessage,
    );
  }
}

class PdfStateNotifier extends StateNotifier<PdfState> {
  PdfStateNotifier() : super(const PdfState());

  void togglePhoto(AssetEntity photo) {
    final current = List<AssetEntity>.from(state.selectedPhotos);
    if (current.any((p) => p.id == photo.id)) {
      current.removeWhere((p) => p.id == photo.id);
    } else {
      current.add(photo);
    }
    state = state.copyWith(selectedPhotos: current);
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    final photos = List<AssetEntity>.from(state.selectedPhotos);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    state = state.copyWith(selectedPhotos: photos);
  }

  void setCreating(bool value) {
    state = state.copyWith(isCreating: value);
  }

  void setPdfPath(String path) {
    state = state.copyWith(createdPdfPath: path, isCreating: false);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isCreating: false);
  }

  void reset() {
    state = const PdfState();
  }
}

/// PDF creation screen
class CreatePdfScreen extends ConsumerStatefulWidget {
  const CreatePdfScreen({super.key});

  @override
  ConsumerState<CreatePdfScreen> createState() => _CreatePdfScreenState();
}

class _CreatePdfScreenState extends ConsumerState<CreatePdfScreen> {
  final PhotoService _photoService = PhotoService();
  final PdfService _pdfService = PdfService();
  List<AssetEntity> _allPhotos = [];
  bool _isLoading = true;
  bool _showReorder = false;

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

  Future<void> _createPdf() async {
    final state = ref.read(pdfStateProvider);
    if (state.selectedPhotos.isEmpty) return;

    ref.read(pdfStateProvider.notifier).setCreating(true);

    final pdfPath = await _pdfService.createPdfFromPhotos(
      photos: state.selectedPhotos,
      title: 'Photos_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (pdfPath != null) {
      ref.read(pdfStateProvider.notifier).setPdfPath(pdfPath);
      if (mounted) {
        _showSuccessDialog(pdfPath);
      }
    } else {
      ref.read(pdfStateProvider.notifier).setError('Failed to create PDF');
    }
  }

  void _showSuccessDialog(String pdfPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '🎉 PDF Created!',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ref.read(pdfStateProvider).selectedPhotos.length} pages',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved to Documents',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await Share.shareXFiles([XFile(pdfPath)]);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Create PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(pdfStateProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (state.selectedPhotos.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _showReorder = !_showReorder);
              },
              child: Text(
                _showReorder ? 'Done' : 'Reorder',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select photos for PDF',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Each photo = 1 page',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
                            ref.read(pdfStateProvider.notifier).reset();
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),

                // Photo grid or reorder list
                Expanded(
                  child: _showReorder && state.selectedPhotos.isNotEmpty
                      ? _buildReorderList(state)
                      : _buildPhotoGrid(state),
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
                child: state.isCreating
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
                              'Creating PDF...',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _createPdf,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(
                          'Create PDF (${state.selectedPhotos.length} pages)',
                          style: const TextStyle(
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
            ),
    );
  }

  Widget _buildPhotoGrid(PdfState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _allPhotos.length,
      itemBuilder: (context, index) {
        final photo = _allPhotos[index];
        final selectedIndex = state.selectedPhotos.indexWhere((p) => p.id == photo.id);
        final isSelected = selectedIndex >= 0;

        return GestureDetector(
          onTap: state.isCreating
              ? null
              : () {
                  ref.read(pdfStateProvider.notifier).togglePhoto(photo);
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
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${selectedIndex + 1}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReorderList(PdfState state) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.selectedPhotos.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(pdfStateProvider.notifier).reorderPhotos(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final photo = state.selectedPhotos[index];
        return Container(
          key: ValueKey(photo.id),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image(
                  image: AssetEntityImageProvider(
                    photo,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize(100, 100),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              'Page ${index + 1}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              photo.title ?? 'Photo',
              style: TextStyle(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.drag_handle,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
