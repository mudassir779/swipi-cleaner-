import 'package:flutter/material.dart';

class StorageCategory {
  final String name;
  final IconData icon;
  final Color color;
  final int bytes;

  const StorageCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.bytes,
  });
}

