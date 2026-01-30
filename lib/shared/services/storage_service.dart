import 'package:shared_preferences/shared_preferences.dart';

/// Service for persistent storage using SharedPreferences
class StorageService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyRecentlyDeletedIds = 'recently_deleted_ids';
  // Settings keys
  static const String _keyAutoCleanWeekly = 'settings_auto_clean_weekly';
  static const String _keyStorageThresholdPct = 'settings_storage_threshold_pct';
  static const String _keyIncludeVideos = 'settings_include_videos';
  static const String _keyFaceRecognition = 'settings_face_recognition';
  static const String _keySecureDeletion = 'settings_secure_deletion';
  static const String _keyAppLockEnabled = 'settings_app_lock_enabled';
  static const String _keyCloudBackup = 'settings_cloud_backup';
  static const String _keyBackupQuality = 'settings_backup_quality';
  static const String _keySyncFrequency = 'settings_sync_frequency';
  static const String _keyCleaningReminders = 'settings_cleaning_reminders';
  static const String _keyStorageAlerts = 'settings_storage_alerts';
  static const String _keyCacheSizeBytes = 'settings_cache_size_bytes';
  static const String _keyIsDarkMode = 'settings_is_dark_mode';

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

  // Settings getters
  bool getAutoCleanWeekly() => _prefs.getBool(_keyAutoCleanWeekly) ?? false;
  int getStorageThresholdPct() => _prefs.getInt(_keyStorageThresholdPct) ?? 80;
  bool getIncludeVideos() => _prefs.getBool(_keyIncludeVideos) ?? true;

  bool getFaceRecognition() => _prefs.getBool(_keyFaceRecognition) ?? false;
  bool getSecureDeletion() => _prefs.getBool(_keySecureDeletion) ?? false;
  bool getAppLockEnabled() => _prefs.getBool(_keyAppLockEnabled) ?? false;

  bool getCloudBackup() => _prefs.getBool(_keyCloudBackup) ?? false;
  String getBackupQuality() => _prefs.getString(_keyBackupQuality) ?? 'Original';
  String getSyncFrequency() => _prefs.getString(_keySyncFrequency) ?? 'Daily';

  bool getCleaningReminders() => _prefs.getBool(_keyCleaningReminders) ?? true;
  bool getStorageAlerts() => _prefs.getBool(_keyStorageAlerts) ?? true;

  int getCacheSizeBytes() => _prefs.getInt(_keyCacheSizeBytes) ?? (245 * 1024 * 1024);
  bool getIsDarkMode() => _prefs.getBool(_keyIsDarkMode) ?? false;

  // Settings setters
  Future<void> setAutoCleanWeekly(bool v) async => _prefs.setBool(_keyAutoCleanWeekly, v);
  Future<void> setStorageThresholdPct(int v) async => _prefs.setInt(_keyStorageThresholdPct, v);
  Future<void> setIncludeVideos(bool v) async => _prefs.setBool(_keyIncludeVideos, v);

  Future<void> setFaceRecognition(bool v) async => _prefs.setBool(_keyFaceRecognition, v);
  Future<void> setSecureDeletion(bool v) async => _prefs.setBool(_keySecureDeletion, v);
  Future<void> setAppLockEnabled(bool v) async => _prefs.setBool(_keyAppLockEnabled, v);

  Future<void> setCloudBackup(bool v) async => _prefs.setBool(_keyCloudBackup, v);
  Future<void> setBackupQuality(String v) async => _prefs.setString(_keyBackupQuality, v);
  Future<void> setSyncFrequency(String v) async => _prefs.setString(_keySyncFrequency, v);

  Future<void> setCleaningReminders(bool v) async => _prefs.setBool(_keyCleaningReminders, v);
  Future<void> setStorageAlerts(bool v) async => _prefs.setBool(_keyStorageAlerts, v);

  Future<void> setCacheSizeBytes(int v) async => _prefs.setInt(_keyCacheSizeBytes, v);
  Future<void> setIsDarkMode(bool v) async => _prefs.setBool(_keyIsDarkMode, v);

  Future<void> resetSettings() async {
    await _prefs.remove(_keyAutoCleanWeekly);
    await _prefs.remove(_keyStorageThresholdPct);
    await _prefs.remove(_keyIncludeVideos);
    await _prefs.remove(_keyFaceRecognition);
    await _prefs.remove(_keySecureDeletion);
    await _prefs.remove(_keyAppLockEnabled);
    await _prefs.remove(_keyCloudBackup);
    await _prefs.remove(_keyBackupQuality);
    await _prefs.remove(_keySyncFrequency);
    await _prefs.remove(_keyCleaningReminders);
    await _prefs.remove(_keyStorageAlerts);
    await _prefs.remove(_keyCacheSizeBytes);
    await _prefs.remove(_keyIsDarkMode);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
