import 'package:shared_preferences/shared_preferences.dart';

/// Service for persistent storage using SharedPreferences
class StorageService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyRecentlyDeletedIds = 'recently_deleted_ids';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  bool getOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Recently deleted IDs
  Future<void> setRecentlyDeletedIds(List<String> ids) async {
    await _prefs.setStringList(_keyRecentlyDeletedIds, ids);
  }

  List<String> getRecentlyDeletedIds() {
    return _prefs.getStringList(_keyRecentlyDeletedIds) ?? [];
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
