import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_bytes.dart';
import '../../../core/widgets/chevron_list_tile.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/switch_list_tile_row.dart';
import '../domain/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final settingsAsync = ref.watch(settingsProvider);
            
            return settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) {
                // Log error to console for debugging
                debugPrint('Settings Error: $e\n$stack');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load settings',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          style: const TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
              data: (s) {
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),

                    // STORAGE
                    _buildAnimatedHeader(0, 'Storage'),
                    _buildAnimatedSection(
                      1,
                      Column(
                        children: [
                          _SwitchChevronRow(
                            title: 'Auto-Clean Schedule',
                            subtitle: 'Clean storage weekly',
                            value: s.autoCleanWeekly,
                            onChanged: (v) => ref.read(settingsProvider.notifier).setAutoCleanWeekly(v),
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.storage_rounded,
                            title: 'Storage Threshold',
                            subtitle: 'Clean when storage > ${s.storageThresholdPct}%',
                            onTap: () => _showThresholdSheet(context, s.storageThresholdPct, (v) {
                              ref.read(settingsProvider.notifier).setStorageThresholdPct(v);
                            }),
                          ),
                          const Divider(height: 1),
                          SwitchListTileRow(
                            leadingIcon: Icons.videocam_rounded,
                            title: 'Include Videos',
                            subtitle: 'Scan videos for duplicates',
                            value: s.includeVideos,
                            onChanged: (v) => ref.read(settingsProvider.notifier).setIncludeVideos(v),
                          ),
                        ],
                      ),
                    ),

                    // PRIVACY & SECURITY
                    _buildAnimatedHeader(2, 'Privacy & Security'),
                    _buildAnimatedSection(
                      3,
                      Column(
                        children: [
                          SwitchListTileRow(
                            leadingIcon: Icons.lock_rounded,
                            title: 'Face Recognition',
                            subtitle: 'Organize by faces',
                            value: s.faceRecognition,
                            onChanged: (v) =>
                                ref.read(settingsProvider.notifier).setFaceRecognition(v),
                          ),
                          const Divider(height: 1),
                          SwitchListTileRow(
                            leadingIcon: Icons.shield_rounded,
                            title: 'Secure Deletion',
                            subtitle: 'Overwrite deleted files',
                            value: s.secureDeletion,
                            onChanged: (v) =>
                                ref.read(settingsProvider.notifier).setSecureDeletion(v),
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.phonelink_lock_rounded,
                            title: 'App Lock',
                            subtitle: s.appLockEnabled ? 'Enabled' : 'Disabled',
                            onTap: () => ref
                                .read(settingsProvider.notifier)
                                .setAppLockEnabled(!s.appLockEnabled),
                          ),
                        ],
                      ),
                    ),

                    // BACKUP & SYNC
                    _buildAnimatedHeader(4, 'Backup & Sync'),
                    _buildAnimatedSection(
                      5,
                      Column(
                        children: [
                          SwitchListTileRow(
                            leadingIcon: Icons.cloud_rounded,
                            title: 'Cloud Backup',
                            subtitle: 'Secure backup of all photos',
                            value: s.cloudBackup,
                            onChanged: (v) =>
                                ref.read(settingsProvider.notifier).setCloudBackup(v),
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.hd_rounded,
                            title: 'Backup Quality',
                            subtitle: s.backupQuality,
                            onTap: () => _showStringPicker(
                              context,
                              title: 'Backup Quality',
                              options: const ['Original', 'High', 'Medium', 'Low'],
                              current: s.backupQuality,
                              onSelected: (v) =>
                                  ref.read(settingsProvider.notifier).setBackupQuality(v),
                            ),
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.sync_rounded,
                            title: 'Sync Frequency',
                            subtitle: s.syncFrequency,
                            onTap: () => _showStringPicker(
                              context,
                              title: 'Sync Frequency',
                              options: const ['Hourly', 'Daily', 'Weekly'],
                              current: s.syncFrequency,
                              onSelected: (v) =>
                                  ref.read(settingsProvider.notifier).setSyncFrequency(v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // NOTIFICATIONS
                    _buildAnimatedHeader(6, 'Notifications'),
                    _buildAnimatedSection(
                      7,
                      Column(
                        children: [
                          SwitchListTileRow(
                            leadingIcon: Icons.notifications_active_rounded,
                            title: 'Cleaning Reminders',
                            value: s.cleaningReminders,
                            onChanged: (v) =>
                                ref.read(settingsProvider.notifier).setCleaningReminders(v),
                          ),
                          const Divider(height: 1),
                          SwitchListTileRow(
                            leadingIcon: Icons.warning_amber_rounded,
                            title: 'Storage Alerts',
                            value: s.storageAlerts,
                            onChanged: (v) =>
                                ref.read(settingsProvider.notifier).setStorageAlerts(v),
                          ),
                        ],
                      ),
                    ),

                    // ADVANCED
                    _buildAnimatedHeader(8, 'Advanced'),
                    _buildAnimatedSection(
                      9,
                      Column(
                        children: [
                          ChevronListTile(
                            leadingIcon: Icons.delete_sweep_rounded,
                            title: 'Clear Cache',
                            subtitle: formatBytes(s.cacheSizeBytes),
                            showChevron: false,
                            trailing: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onTap: () => _confirm(
                              context,
                              title: 'Clear Cache?',
                              message: 'This will remove cached thumbnails and temporary data.',
                              confirmText: 'Clear',
                              onConfirm: () =>
                                  ref.read(settingsProvider.notifier).clearCache(),
                            ),
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.restart_alt_rounded,
                            title: 'Reset All Settings',
                            subtitle: 'Restore defaults',
                            showChevron: false,
                            trailing: const Text(
                              'Reset',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onTap: () => _confirm(
                              context,
                              title: 'Reset all settings?',
                              message: 'This will restore all settings back to defaults.',
                              confirmText: 'Reset',
                              onConfirm: () =>
                                  ref.read(settingsProvider.notifier).resetAllSettings(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ABOUT
                    _buildAnimatedHeader(12, 'About'),
                    _buildAnimatedSection(
                      13,
                      Column(
                        children: [
                          const ChevronListTile(
                            leadingIcon: Icons.info_outline_rounded,
                            title: 'Version',
                            subtitle: '1.0.0',
                            showChevron: false,
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Privacy Policy coming soon'))),
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.description_outlined,
                            title: 'Terms of Service',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Terms coming soon'))),
                          ),
                          const Divider(height: 1),
                          ChevronListTile(
                            leadingIcon: Icons.badge_outlined,
                            title: 'Licenses',
                            onTap: () => showLicensePage(context: context),
                          ),
                          const SizedBox(height: 28),
                          const Icon(Icons.photo_library_outlined,
                              color: AppColors.textSecondary),
                          const SizedBox(height: 10),
                          const Text(
                            '© 2026 Swipe to Clean',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(int index, String title) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(title: title),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Calculate delay based on index, but ensure it never exceeds valid range
          // Using smaller step (0.05) to fit more items, and clamping start time
          final double begin = (index * 0.05).clamp(0.0, 0.6);
          final double end = (begin + 0.4).clamp(0.0, 1.0);
          
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                begin,
                end,
                curve: Curves.easeOutCubic,
              ),
            ),
          );

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                begin,
                end,
                curve: Curves.easeOut,
              ),
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  const _StickyHeaderDelegate({required this.title});

  @override
  double get minExtent => 38;

  @override
  double get maxExtent => 38;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SectionHeader(title: title);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) =>
      oldDelegate.title != title;
}

class _SwitchChevronRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchChevronRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.titleMedium?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.green,
            activeTrackColor: AppColors.green.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: theme.textTheme.bodySmall?.color),
        ],
      ),
      onTap: () => onChanged(!value),
    );
  }
}

Future<void> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  required Future<void> Function() onConfirm,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  if (res == true) {
    await onConfirm();
  }
}

Future<void> _showStringPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String current,
  required ValueChanged<String> onSelected,
}) async {
  final res = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          for (final option in options)
            ListTile(
              title: Text(option),
              trailing: option == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(ctx, option),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (res != null) onSelected(res);
}

Future<void> _showThresholdSheet(
  BuildContext context,
  int current,
  ValueChanged<int> onSelected,
) async {
  int temp = current;
  final res = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Storage Threshold',
                style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  Text(
                    'Clean when storage > $temp%',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700),
                  ),
                  Slider(
                    value: temp.toDouble(),
                    min: 50,
                    max: 95,
                    divisions: 9,
                    label: '$temp%',
                    onChanged: (v) => setState(() => temp = v.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, temp),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (res != null) onSelected(res);
}
