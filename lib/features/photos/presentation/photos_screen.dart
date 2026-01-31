import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/photo_grid_item.dart';
import '../../../core/widgets/skeleton_loading.dart';
import '../../../app/main_scaffold.dart';
import '../domain/providers/month_photos_provider.dart';
import '../domain/providers/delete_queue_provider.dart';
import '../domain/providers/photo_selection_provider.dart';
import 'widgets/app_drawer.dart';

/// Provider for managing expanded state of month sections
final expandedMonthsProvider = StateNotifierProvider<ExpandedMonthsNotifier, Map<String, bool>>((ref) {
  return ExpandedMonthsNotifier();
});

class ExpandedMonthsNotifier extends StateNotifier<Map<String, bool>> {
  ExpandedMonthsNotifier() : super({}) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('month_expanded_'));
    final newState = <String, bool>{};
    for (final key in keys) {
      final monthKey = key.replaceFirst('month_expanded_', '');
      newState[monthKey] = prefs.getBool(key) ?? true;
    }
    state = newState;
  }

  Future<void> toggle(String monthKey) async {
    final current = state[monthKey] ?? true;
    state = {...state, monthKey: !current};
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('month_expanded_$monthKey', !current);
  }

  bool isExpanded(String monthKey) {
    return state[monthKey] ?? true; // Default to expanded
  }
}

/// Photos screen with collapsible month-by-month organization
class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthGroupsAsync = ref.watch(monthPhotosProvider);
    final selection = ref.watch(photoSelectionProvider);
    final expandedMonths = ref.watch(expandedMonthsProvider);

    return MainScaffold(
      currentIndex: 1,
      child: Scaffold(
      // backgroundColor: removed to use theme default
      drawerScrimColor: Colors.black.withValues(alpha: 0.45),
      drawer: const AppDrawer(),
      floatingActionButton: _buildQuickCleanButton(context, ref),
      appBar: AppBar(
        // backgroundColor: removed to use theme default
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 60,
        leading: selection.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
                onPressed: () => ref.read(photoSelectionProvider.notifier).exitSelectionMode(),
                tooltip: 'Exit selection',
              )
            : Builder(
                builder: (context) => _AnimatedMenuButton(
                  onTap: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Text(
          selection.isSelectionMode ? '${selection.count} Selected' : 'Photos',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: selection.isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                  tooltip: 'Add to delete queue',
                  onPressed: selection.count == 0
                      ? null
                      : () {
                          ref.read(deleteQueueProvider.notifier).addAll(selection.selectedIds.toList());
                          ref.read(photoSelectionProvider.notifier).exitSelectionMode();
                          context.push('/confirm-delete');
                        },
                ),
              ]
            : null,
      ),
      body: monthGroupsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(2),
          child: PhotoGridSkeleton(itemCount: 24),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading photos',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (monthGroups) {
          if (monthGroups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Photos',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your photos will appear here',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(monthPhotosProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: monthGroups.length,
              itemBuilder: (context, index) {
                final monthGroup = monthGroups[index];
                final isExpanded = expandedMonths[monthGroup.monthKey] ?? true;
                
                return _CollapsibleMonthSection(
                  monthGroup: monthGroup,
                  isExpanded: isExpanded,
                  onToggle: () {
                    HapticFeedback.lightImpact();
                    ref.read(expandedMonthsProvider.notifier).toggle(monthGroup.monthKey);
                  },
                  ref: ref,
                );
              },
            ),
          );
        },
      ),
    ),
    );
  }

  /// Build floating quick clean button (shows when today has photos)
  Widget? _buildQuickCleanButton(BuildContext context, WidgetRef ref) {
    final todayPhotosAsync = ref.watch(todayPhotosProvider);

    return todayPhotosAsync.when(
      data: (photos) {
        // Only show button if today has photos
        if (photos.isEmpty) return null;

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.gradientPrimary,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/swipe-review?filter=today'),
              borderRadius: BorderRadius.circular(30),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Clean Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => null,
      error: (error, stack) => null,
    );
  }
}

/// Collapsible month section with smooth animations
class _CollapsibleMonthSection extends StatelessWidget {
  final dynamic monthGroup;
  final bool isExpanded;
  final VoidCallback onToggle;
  final WidgetRef ref;

  const _CollapsibleMonthSection({
    required this.monthGroup,
    required this.isExpanded,
    required this.onToggle,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = monthGroup.photoCount == 0;
    final selection = ref.watch(photoSelectionProvider);

    return Column(
      children: [
        // Collapsible Month Header
        InkWell(
          onTap: onToggle,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Purple dot indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? AppColors.textSecondary.withValues(alpha: 0.3)
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Month name
                Text(
                  monthGroup.displayName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isEmpty
                        ? AppColors.textSecondary.withValues(alpha: 0.5)
                        : Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const Spacer(),
                // Photo count
                Text(
                  '${monthGroup.photoCount} photos',
                  style: TextStyle(
                    fontSize: 15,
                    color: isEmpty
                        ? AppColors.textSecondary.withValues(alpha: 0.5)
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                // Animated chevron
                AnimatedRotation(
                  turns: isExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Collapsible Photos Grid
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded && !isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: monthGroup.photos.length,
                    itemBuilder: (context, photoIndex) {
                      final photo = monthGroup.photos[photoIndex];
                      final isSelected = selection.selectedIds.contains(photo.id);
                      return PhotoGridItem(
                        asset: photo.asset,
                        isSelected: isSelected,
                        onTap: () {
                          if (selection.isSelectionMode) {
                            ref.read(photoSelectionProvider.notifier).toggle(photo.id);
                            return;
                          }
                          context.push('/swipe-review?month=${monthGroup.monthKey}&start=$photoIndex');
                        },
                        onLongPress: () {
                          if (!selection.isSelectionMode) {
                            ref.read(photoSelectionProvider.notifier).enterSelectionMode(initialId: photo.id);
                          } else {
                            ref.read(photoSelectionProvider.notifier).toggle(photo.id);
                          }
                        },
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}


/// Animated Menu Button with scale effect and premium styling
class _AnimatedMenuButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedMenuButton({required this.onTap});

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLine(width: 22),
              const SizedBox(height: 4),
              _buildLine(width: 16),
              const SizedBox(height: 4),
              _buildLine(width: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine({required double width}) {
    return Container(
      width: width,
      height: 2.5,
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
