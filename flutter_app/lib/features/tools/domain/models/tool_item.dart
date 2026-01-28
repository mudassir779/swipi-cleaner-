import 'package:flutter/material.dart';

/// Tool item model
class ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String route;

  const ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
  });
}

/// Tool category
class ToolCategory {
  final String title;
  final List<ToolItem> tools;

  const ToolCategory({
    required this.title,
    required this.tools,
  });
}
