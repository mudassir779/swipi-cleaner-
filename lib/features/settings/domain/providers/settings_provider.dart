import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/storage_service.dart';
import '../models/settings_state.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsController extends AsyncNotifier<SettingsState> {
  late final StorageService _storage;

  @override
  Future<SettingsState> build() async {
    _storage = StorageService();
    await _storage.init();

    return SettingsState(
      autoCleanWeekly: _storage.getAutoCleanWeekly(),
      storageThresholdPct: _storage.getStorageThresholdPct(),
      includeVideos: _storage.getIncludeVideos(),
      faceRecognition: _storage.getFaceRecognition(),
      secureDeletion: _storage.getSecureDeletion(),
      appLockEnabled: _storage.getAppLockEnabled(),
      cloudBackup: _storage.getCloudBackup(),
      backupQuality: _storage.getBackupQuality(),
      syncFrequency: _storage.getSyncFrequency(),
      cleaningReminders: _storage.getCleaningReminders(),
      storageAlerts: _storage.getStorageAlerts(),
      cacheSizeBytes: _storage.getCacheSizeBytes(),
      isDarkMode: _storage.getIsDarkMode(),
    );
  }

  Future<void> setAutoCleanWeekly(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(autoCleanWeekly: v));
    await _storage.setAutoCleanWeekly(v);
  }

  Future<void> setStorageThresholdPct(int v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(storageThresholdPct: v));
    await _storage.setStorageThresholdPct(v);
  }

  Future<void> setIncludeVideos(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(includeVideos: v));
    await _storage.setIncludeVideos(v);
  }

  Future<void> setFaceRecognition(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(faceRecognition: v));
    await _storage.setFaceRecognition(v);
  }

  Future<void> setSecureDeletion(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(secureDeletion: v));
    await _storage.setSecureDeletion(v);
  }

  Future<void> setAppLockEnabled(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(appLockEnabled: v));
    await _storage.setAppLockEnabled(v);
  }

  Future<void> setCloudBackup(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(cloudBackup: v));
    await _storage.setCloudBackup(v);
  }

  Future<void> setBackupQuality(String v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(backupQuality: v));
    await _storage.setBackupQuality(v);
  }

  Future<void> setSyncFrequency(String v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(syncFrequency: v));
    await _storage.setSyncFrequency(v);
  }

  Future<void> setCleaningReminders(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(cleaningReminders: v));
    await _storage.setCleaningReminders(v);
  }

  Future<void> setStorageAlerts(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(storageAlerts: v));
    await _storage.setStorageAlerts(v);
  }

  Future<void> clearCache() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(cacheSizeBytes: 0));
    await _storage.setCacheSizeBytes(0);
  }

  Future<void> setDarkMode(bool v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isDarkMode: v));
    await _storage.setIsDarkMode(v);
  }

  Future<void> resetAllSettings() async {
    await _storage.resetSettings();
    state = AsyncData(
      SettingsState(
        autoCleanWeekly: _storage.getAutoCleanWeekly(),
        storageThresholdPct: _storage.getStorageThresholdPct(),
        includeVideos: _storage.getIncludeVideos(),
        faceRecognition: _storage.getFaceRecognition(),
        secureDeletion: _storage.getSecureDeletion(),
        appLockEnabled: _storage.getAppLockEnabled(),
        cloudBackup: _storage.getCloudBackup(),
        backupQuality: _storage.getBackupQuality(),
        syncFrequency: _storage.getSyncFrequency(),
        cleaningReminders: _storage.getCleaningReminders(),
        storageAlerts: _storage.getStorageAlerts(),
        cacheSizeBytes: _storage.getCacheSizeBytes(),
        isDarkMode: _storage.getIsDarkMode(),
      ),
    );
  }
}

