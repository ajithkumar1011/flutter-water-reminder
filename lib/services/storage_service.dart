import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const String _remindersKey = 'custom_reminders';
  static const String _autoReminderKey = 'auto_reminder_enabled';

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
}
