import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final DateTime dateTime;
  final String title;
  final String body;
  final bool isAutoReminder;

  const ReminderModel({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.body,
    this.isAutoReminder = false,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      title: json['title'],
      body: json['body'],
      isAutoReminder: json['isAutoReminder'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'title': title,
      'body': body,
      'isAutoReminder': isAutoReminder,
    };
  }

  @override
  List<Object> get props => [id, dateTime, title, body, isAutoReminder];
}
