class SettingsState {
  final bool autoCleanWeekly;
  final int storageThresholdPct;
  final bool includeVideos;

  final bool faceRecognition;
  final bool secureDeletion;
  final bool appLockEnabled;

  final bool cloudBackup;
  final String backupQuality;
  final String syncFrequency;

  final bool cleaningReminders;
  final bool storageAlerts;

  final int cacheSizeBytes;

  const SettingsState({
    required this.autoCleanWeekly,
    required this.storageThresholdPct,
    required this.includeVideos,
    required this.faceRecognition,
    required this.secureDeletion,
    required this.appLockEnabled,
    required this.cloudBackup,
    required this.backupQuality,
    required this.syncFrequency,
    required this.cleaningReminders,
    required this.storageAlerts,
    required this.cacheSizeBytes,
  });

  SettingsState copyWith({
    bool? autoCleanWeekly,
    int? storageThresholdPct,
    bool? includeVideos,
    bool? faceRecognition,
    bool? secureDeletion,
    bool? appLockEnabled,
    bool? cloudBackup,
    String? backupQuality,
    String? syncFrequency,
    bool? cleaningReminders,
    bool? storageAlerts,
    int? cacheSizeBytes,
  }) {
    return SettingsState(
      autoCleanWeekly: autoCleanWeekly ?? this.autoCleanWeekly,
      storageThresholdPct: storageThresholdPct ?? this.storageThresholdPct,
      includeVideos: includeVideos ?? this.includeVideos,
      faceRecognition: faceRecognition ?? this.faceRecognition,
      secureDeletion: secureDeletion ?? this.secureDeletion,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      cloudBackup: cloudBackup ?? this.cloudBackup,
      backupQuality: backupQuality ?? this.backupQuality,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      cleaningReminders: cleaningReminders ?? this.cleaningReminders,
      storageAlerts: storageAlerts ?? this.storageAlerts,
      cacheSizeBytes: cacheSizeBytes ?? this.cacheSizeBytes,
    );
  }
}

