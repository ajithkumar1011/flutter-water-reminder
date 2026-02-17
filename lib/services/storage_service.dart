import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const String _remindersKey = 'custom_reminders';
  static const String _autoReminderKey = 'auto_reminder_enabled';
  static const String _autoReminderTimeKey = 'auto_reminder_scheduled_time';

  static Future<List<ReminderModel>> getCustomReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey) ?? [];

    return remindersJson
        .map((json) => ReminderModel.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> saveCustomReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson =
        reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();

    await prefs.setStringList(_remindersKey, remindersJson);
  }

  static Future<bool> isAutoReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoReminderKey) ?? false;
  }

  static Future<void> setAutoReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoReminderKey, enabled);
  }

  /// Get the scheduled time for the next auto reminder
  static Future<DateTime?> getAutoReminderScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_autoReminderTimeKey);
    if (timeString == null) return null;
    return DateTime.parse(timeString);
  }

  /// Save the scheduled time for the next auto reminder
  static Future<void> setAutoReminderScheduledTime(DateTime? time) async {
    final prefs = await SharedPreferences.getInstance();
    if (time == null) {
      await prefs.remove(_autoReminderTimeKey);
    } else {
      await prefs.setString(_autoReminderTimeKey, time.toIso8601String());
    }
  }
}
