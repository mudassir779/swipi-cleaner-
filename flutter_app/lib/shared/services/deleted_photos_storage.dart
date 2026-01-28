import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Simple model for persisting deleted photo metadata
class DeletedPhotoData {
  final String id;
  final DateTime deletedAt;

  DeletedPhotoData({
    required this.id,
    required this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'deletedAt': deletedAt.toIso8601String(),
  };

  factory DeletedPhotoData.fromJson(Map<String, dynamic> json) => DeletedPhotoData(
    id: json['id'] as String,
    deletedAt: DateTime.parse(json['deletedAt'] as String),
  );

  /// Days remaining until permanent deletion
  int get daysRemaining {
    final daysSinceDeleted = DateTime.now().difference(deletedAt).inDays;
    return 30 - daysSinceDeleted;
  }

  /// Check if expired (past 30 days)
  bool get isExpired => daysRemaining <= 0;
}

/// Local storage for deleted photos using SharedPreferences
/// Note: Only stores photo ID and deletion timestamp (AssetEntity cannot be serialized)
class DeletedPhotosStorage {
  static const _key = 'deleted_photos';

  /// Save deleted photo metadata to local storage
  Future<void> saveDeletedItems(List<DeletedPhotoData> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      // Fail silently - don't block deletion if storage fails
      print('Error saving deleted items: $e');
    }
  }

  /// Load deleted photo metadata from local storage, filtering out expired items (>30 days)
  Future<List<DeletedPhotoData>> loadDeletedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      final now = DateTime.now();

      // Filter out items older than 30 days
      return jsonList
          .map((json) => DeletedPhotoData.fromJson(json as Map<String, dynamic>))
          .where((item) => item.deletedAt.add(const Duration(days: 30)).isAfter(now))
          .toList();
    } catch (e) {
      // Return empty list if parsing fails
      print('Error loading deleted items: $e');
      return [];
    }
  }

  /// Clear all deleted items from storage
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing deleted items: $e');
    }
  }
}
