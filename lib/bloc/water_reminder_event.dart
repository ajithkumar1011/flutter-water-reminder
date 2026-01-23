import 'package:equatable/equatable.dart';
import '../models/reminder_model.dart';

abstract class WaterReminderEvent extends Equatable {
  const WaterReminderEvent();

  @override
  List<Object> get props => [];
}

class InitializeReminders extends WaterReminderEvent {}

class AddCustomReminder extends WaterReminderEvent {
  final ReminderModel reminder;

  const AddCustomReminder(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class DeleteCustomReminder extends WaterReminderEvent {
  final String reminderId;

  const DeleteCustomReminder(this.reminderId);

  @override
  List<Object> get props => [reminderId];
}

class ToggleAutoReminder extends WaterReminderEvent {
  final bool enabled;

  const ToggleAutoReminder(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class LoadReminders extends WaterReminderEvent {}

class ShowInstantNotification extends WaterReminderEvent {}
