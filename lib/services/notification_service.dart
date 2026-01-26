import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:water_reminder_app/models/reminder_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int autoReminderId = 0;

  /// 🔹 INIT (call once in main)
  static Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _notifications.initialize(settings);

    const channel = AndroidNotificationChannel(
      'water_reminder_channel',
      'Water Reminder Notifications',
      description: 'Water drinking reminders',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 🔹 Permissions
  static Future<void> requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  static Future<void> scheduleNotification(ReminderModel reminder) async {
    final scheduledTime = tz.TZDateTime.from(reminder.dateTime, tz.local);

    // ⛔ Do not schedule past notifications
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'water_reminder_channel',
        'Water Reminder Notifications',
        channelDescription: 'Water drinking reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode, // UNIQUE ID per reminder
      reminder.title,
      reminder.body,
      scheduledTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 🔹 AUTO REMINDER (every 2 hours)
  static Future<void> scheduleAutoReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    final nextTime = now.add(const Duration(hours: 2));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'water_reminder_channel',
        'Water Reminder Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.zonedSchedule(
      autoReminderId,
      '💧 Time to Drink Water',
      'Stay hydrated and healthy!',
      nextTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 🔹 Cancel auto reminder
  static Future<void> cancelAutoReminder() async {
    await _notifications.cancel(autoReminderId);
  }

  /// 🔹 Test notification
  static Future<void> showInstantNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'water_reminder_channel',
        'Water Reminder Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Test Notification',
      'Notification is working 🎉',
      details,
    );
  }
}
