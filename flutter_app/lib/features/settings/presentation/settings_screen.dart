import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  'Swipe to Clean Storage User',
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
            subtitle: 'Learn more about Swipe to Clean Storage',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Swipe to Clean Storage'),
                    ],
                  ),
                  content: const Text(
                    'A modern photo cleanup app to help you organize and free up storage space.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'We do not collect or store your data',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const Text(
                    'Swipe to Clean Storage respects your privacy.\n\n'
                    '• We do not collect any personal data\n'
                    '• We do not store your photos on our servers\n'
                    '• All photo processing happens locally on your device\n'
                    '• Your photos remain private and secure',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
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
