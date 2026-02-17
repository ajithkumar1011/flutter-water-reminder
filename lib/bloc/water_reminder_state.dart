import 'package:equatable/equatable.dart';
import '../models/reminder_model.dart';

enum WaterReminderStatus { initial, loading, success, error }

class WaterReminderState extends Equatable {
  const WaterReminderState({
    this.status = WaterReminderStatus.initial,
    this.customReminders = const [],
    this.isAutoReminderEnabled = false,
    this.nextAutoReminderTime,
    this.errorMessage,
  });

  final WaterReminderStatus status;
  final List<ReminderModel> customReminders;
  final bool isAutoReminderEnabled;
  final DateTime? nextAutoReminderTime;
  final String? errorMessage;

  WaterReminderState copyWith({
    WaterReminderStatus? status,
    List<ReminderModel>? customReminders,
    bool? isAutoReminderEnabled,
    DateTime? nextAutoReminderTime,
    String? errorMessage,
  }) {
    return WaterReminderState(
      status: status ?? this.status,
      customReminders: customReminders ?? this.customReminders,
      isAutoReminderEnabled:
          isAutoReminderEnabled ?? this.isAutoReminderEnabled,
      nextAutoReminderTime: nextAutoReminderTime ?? this.nextAutoReminderTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customReminders,
        isAutoReminderEnabled,
        nextAutoReminderTime,
        errorMessage,
      ];
}
