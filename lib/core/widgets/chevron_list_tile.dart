import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ChevronListTile extends StatelessWidget {
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const ChevronListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingIconColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: leadingIcon == null
          ? null
          : Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.slateIcon,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                leadingIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
      trailing: trailing ??
          (showChevron
              ? const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                )
              : null),
      onTap: onTap,
    );
  }
}

