import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../../shared/services/social_media_service.dart';

/// Provider for social media service
final socialMediaServiceProvider = Provider((ref) => SocialMediaService());

/// Provider for WhatsApp files
final whatsAppFilesProvider = FutureProvider<List<SocialMediaFile>>((ref) async {
  final service = ref.read(socialMediaServiceProvider);
  return await service.getWhatsAppFiles();
});

/// Provider for Telegram files
final telegramFilesProvider = FutureProvider<List<SocialMediaFile>>((ref) async {
  final service = ref.read(socialMediaServiceProvider);
  return await service.getTelegramFiles();
});

/// Provider for platform support check
final socialMediaSupportedProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(socialMediaServiceProvider);
  return await service.isSupported();
});

/// Social Media Cleaner screen with tabs for WhatsApp and Telegram
class SocialMediaCleanerScreen extends ConsumerStatefulWidget {
  const SocialMediaCleanerScreen({super.key});

  @override
  ConsumerState<SocialMediaCleanerScreen> createState() => _SocialMediaCleanerScreenState();
}

class _SocialMediaCleanerScreenState extends ConsumerState<SocialMediaCleanerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedWhatsApp = {};
  final Set<String> _selectedTelegram = {};
  bool _isDeleting = false;
  SocialMediaFileType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Set<String> get _currentSelection =>
      _tabController.index == 0 ? _selectedWhatsApp : _selectedTelegram;

  void _toggleSelection(String path) {
    final selection = _currentSelection;
    setState(() {
      if (selection.contains(path)) {
        selection.remove(path);
      } else {
        selection.add(path);
      }
    });
  }

  void _selectAll(List<SocialMediaFile> files) {
    final selection = _currentSelection;
    setState(() {
      selection.clear();
      selection.addAll(files.map((f) => f.file.path));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedWhatsApp.clear();
      _selectedTelegram.clear();
    });
  }

  Future<void> _deleteSelected(List<SocialMediaFile> files) async {
    final selection = _currentSelection;
    if (selection.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Files?'),
        content: Text(
          'Delete ${selection.length} files? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    final toDelete = files.where((f) => selection.contains(f.file.path)).toList();
    final service = ref.read(socialMediaServiceProvider);
    final deleted = await service.deleteFiles(toDelete);

    setState(() {
      _isDeleting = false;
      selection.clear();
    });

    // Refresh the provider
    if (_tabController.index == 0) {
      ref.invalidate(whatsAppFilesProvider);
    } else {
      ref.invalidate(telegramFilesProvider);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $deleted files'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  List<SocialMediaFile> _filterFiles(List<SocialMediaFile> files) {
    if (_filterType == null) return files;
    return files.where((f) => f.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final supportedAsync = ref.watch(socialMediaSupportedProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Social Media Cleaner',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(
              icon: Icon(Icons.message, color: Color(0xFF25D366)),
              text: 'WhatsApp',
            ),
            Tab(
              icon: Icon(Icons.send, color: Color(0xFF0088CC)),
              text: 'Telegram',
            ),
          ],
        ),
      ),
      body: supportedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: AppColors.error)),
        ),
        data: (isSupported) {
          if (!isSupported) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smartphone,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Platform.isIOS
                          ? 'Not Available on iOS'
                          : 'No Social Media Apps Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Platform.isIOS
                          ? 'iOS doesn\'t allow access to other app folders. This feature is only available on Android.'
                          : 'WhatsApp or Telegram folders were not found on this device.',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFileList(ref.watch(whatsAppFilesProvider), _selectedWhatsApp),
              _buildFileList(ref.watch(telegramFilesProvider), _selectedTelegram),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFileList(AsyncValue<List<SocialMediaFile>> filesAsync, Set<String> selection) {
    return filesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error scanning files', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(e.toString(), style: AppTextStyles.body),
          ],
        ),
      ),
      data: (files) {
        final filteredFiles = _filterFiles(files);

        if (files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'No files found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This app folder is empty or inaccessible',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        final totalSize = files.fold<int>(0, (sum, f) => sum + f.size);
        final imageCount = files.where((f) => f.type == SocialMediaFileType.image).length;
        final videoCount = files.where((f) => f.type == SocialMediaFileType.video).length;
        final audioCount = files.where((f) => f.type == SocialMediaFileType.audio).length;

        return Column(
          children: [
            // Stats header
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardTheme.color,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${files.length} files found',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatBytes(totalSize),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (selection.isNotEmpty)
                        TextButton(
                          onPressed: _clearSelection,
                          child: const Text('Clear'),
                        )
                      else
                        TextButton(
                          onPressed: () => _selectAll(filteredFiles),
                          child: const Text('Select All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          count: files.length,
                          isSelected: _filterType == null,
                          onTap: () => setState(() => _filterType = null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Images',
                          count: imageCount,
                          isSelected: _filterType == SocialMediaFileType.image,
                          onTap: () => setState(() => _filterType = SocialMediaFileType.image),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Videos',
                          count: videoCount,
                          isSelected: _filterType == SocialMediaFileType.video,
                          onTap: () => setState(() => _filterType = SocialMediaFileType.video),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Audio',
                          count: audioCount,
                          isSelected: _filterType == SocialMediaFileType.audio,
                          onTap: () => setState(() => _filterType = SocialMediaFileType.audio),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // File list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredFiles.length,
                itemBuilder: (context, index) {
                  final file = filteredFiles[index];
                  final isSelected = selection.contains(file.file.path);

                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getTypeColor(file.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(file.type),
                        color: _getTypeColor(file.type),
                      ),
                    ),
                    title: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      formatBytes(file.size),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(file.file.path),
                      activeColor: AppColors.error,
                    ),
                    onTap: () => _toggleSelection(file.file.path),
                  );
                },
              ),
            ),

            // Bottom action bar
            if (selection.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: SafeArea(
                  child: _isDeleting
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
                              Text('Deleting...'),
                            ],
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => _deleteSelected(filteredFiles),
                          icon: const Icon(Icons.delete_outline),
                          label: Text('Delete ${selection.length} files'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }

  IconData _getTypeIcon(SocialMediaFileType type) {
    switch (type) {
      case SocialMediaFileType.image:
        return Icons.image;
      case SocialMediaFileType.video:
        return Icons.videocam;
      case SocialMediaFileType.audio:
        return Icons.audiotrack;
      case SocialMediaFileType.document:
        return Icons.description;
      case SocialMediaFileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor(SocialMediaFileType type) {
    switch (type) {
      case SocialMediaFileType.image:
        return const Color(0xFF4FACFE);
      case SocialMediaFileType.video:
        return const Color(0xFFFF6B6B);
      case SocialMediaFileType.audio:
        return const Color(0xFF667EEA);
      case SocialMediaFileType.document:
        return const Color(0xFF11998E);
      case SocialMediaFileType.other:
        return AppColors.textSecondary;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.divider,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
