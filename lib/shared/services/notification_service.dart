import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Keys for notification settings
class NotificationPrefsKeys {
  static const cleanupReminders = 'notification_cleanup_reminders';
  static const storageAlerts = 'notification_storage_alerts';
}

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could open specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Check if cleanup reminders are enabled
  Future<bool> isCleanupRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(NotificationPrefsKeys.cleanupReminders) ?? false;
  }

  /// Enable/disable cleanup reminders
  Future<void> setCleanupRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NotificationPrefsKeys.cleanupReminders, enabled);

    if (enabled) {
      await _scheduleWeeklyCleanupReminder();
    } else {
      await _notifications.cancel(1); // ID for cleanup reminder
    }
  }

  /// Check if storage alerts are enabled
  Future<bool> isStorageAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(NotificationPrefsKeys.storageAlerts) ?? false;
  }

  /// Enable/disable storage alerts
  Future<void> setStorageAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NotificationPrefsKeys.storageAlerts, enabled);
  }

  /// Schedule weekly cleanup reminder
  Future<void> _scheduleWeeklyCleanupReminder() async {
    await _notifications.zonedSchedule(
      1, // Notification ID
      '📱 Time to Clean Up!',
      'Your phone might have duplicate photos or old files. Tap to review.',
      _nextWeekday(DateTime.saturday, 10), // Saturday at 10 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cleanup_reminders',
          'Cleanup Reminders',
          channelDescription: 'Weekly reminders to clean up your photos',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'cleanup_reminder',
    );
  }

  /// Show storage alert notification
  Future<void> showStorageAlert(int usedPercent) async {
    final alertsEnabled = await isStorageAlertsEnabled();
    if (!alertsEnabled) return;

    if (usedPercent < 80) return; // Only alert above 80%

    await _notifications.show(
      2, // Notification ID
      '⚠️ Storage Almost Full',
      'Your storage is $usedPercent% full. Clean up to free space.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'storage_alerts',
          'Storage Alerts',
          channelDescription: 'Alerts when storage is running low',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'storage_alert',
    );
  }

  /// Show cleanup success notification
  Future<void> showCleanupSuccess(int itemsDeleted, String spaceFreed) async {
    await _notifications.show(
      3, // Notification ID
      '🎉 Cleanup Complete!',
      'Deleted $itemsDeleted items and freed $spaceFreed',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cleanup_success',
          'Cleanup Success',
          channelDescription: 'Notifications when cleanup is complete',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      payload: 'cleanup_success',
    );
  }

  /// Calculate next occurrence of a weekday at a specific hour
  tz.TZDateTime _nextWeekday(int weekday, int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
