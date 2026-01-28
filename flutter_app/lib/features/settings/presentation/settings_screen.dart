import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/permission_service.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User section (placeholder)
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Clean Gallery User',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Free Plan',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Storage section
          _buildSectionHeader('STORAGE'),
          _buildListTile(
            icon: Icons.storage,
            title: 'Storage Stats',
            subtitle: 'View detailed storage information',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage stats coming soon')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.delete_sweep,
            title: 'Recently Deleted',
            subtitle: 'View and restore deleted photos',
            onTap: () => context.push('/recently-deleted'),
          ),

          const Divider(height: 1),

          // Permissions section
          _buildSectionHeader('PERMISSIONS'),
          _buildListTile(
            icon: Icons.photo_library,
            title: 'Photo Access',
            subtitle: 'Manage photo library permissions',
            onTap: () async {
              final permissionService = PermissionService();
              final status = await permissionService.getPhotoPermissionStatus();

              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Photo Access'),
                    content: Text(
                      'Current status: ${_getPermissionStatusText(status)}\n\n'
                      'Tap "Open Settings" to modify permissions.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await openAppSettings();
                          } catch (e) {
                            // openAppSettings may not be available
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          const Divider(height: 1),

          // App section
          _buildSectionHeader('APP'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Clean Gallery',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                children: [
                  const Text(
                    'A modern photo cleanup app to help you organize and free up storage space.',
                  ),
                ],
              );
            },
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of service coming soon')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support coming soon')),
              );
            },
          ),

          const SizedBox(height: 32),

          // App info
          Center(
            child: Text(
              'Made with Flutter 💙',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Clean Gallery v1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.sectionHeader,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.sectionHeader,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  String _getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted - Full access';
      case PermissionStatus.limited:
        return 'Limited - Selected photos only';
      case PermissionStatus.denied:
        return 'Denied - No access';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently denied';
      case PermissionStatus.restricted:
        return 'Restricted by system';
      case PermissionStatus.provisional:
        return 'Provisional access';
    }
  }
}
