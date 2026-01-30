import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class CategoryItem {
  final String id;
  final String title;
  final IconData icon;
  final Color accent;
  final int count;
  final List<AssetEntity> previews;
  final bool comingSoon;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.accent,
    required this.count,
    required this.previews,
    this.comingSoon = false,
  });
}

