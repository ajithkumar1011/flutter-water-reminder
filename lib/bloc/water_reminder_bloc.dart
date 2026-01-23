import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'water_reminder_event.dart';
import 'water_reminder_state.dart';

class WaterReminderBloc extends Bloc<WaterReminderEvent, WaterReminderState> {
  WaterReminderBloc() : super(const WaterReminderState()) {
    on<InitializeReminders>(_onInitializeReminders);
    on<AddCustomReminder>(_onAddCustomReminder);
    on<DeleteCustomReminder>(_onDeleteCustomReminder);
    on<ToggleAutoReminder>(_onToggleAutoReminder);
    on<LoadReminders>(_onLoadReminders);
    on<ShowInstantNotification>(_onShowInstantNotification);
  }

  Future<void> _onInitializeReminders(
    InitializeReminders event,
    Emitter<WaterReminderState> emit,
  ) async {
    emit(state.copyWith(status: WaterReminderStatus.loading));

    try {
      final customReminders = await StorageService.getCustomReminders();
      final isAutoEnabled = await StorageService.isAutoReminderEnabled();

      DateTime? nextAutoTime;
      if (isAutoEnabled) {
        nextAutoTime = DateTime.now().add(const Duration(hours: 2));
      }

      emit(state.copyWith(
        status: WaterReminderStatus.success,
        customReminders: customReminders,
        isAutoReminderEnabled: isAutoEnabled,
        nextAutoReminderTime: nextAutoTime,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCustomReminder(
    AddCustomReminder event,
    Emitter<WaterReminderState> emit,
  ) async {
    try {
      // Schedule the notification
      await NotificationService.scheduleNotification(event.reminder);

      // Add to local list
      final updatedReminders = [...state.customReminders, event.reminder];

      // Save to storage
      await StorageService.saveCustomReminders(updatedReminders);

      emit(state.copyWith(
        customReminders: updatedReminders,
        status: WaterReminderStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteCustomReminder(
    DeleteCustomReminder event,
    Emitter<WaterReminderState> emit,
  ) async {
    try {
      // Cancel the notification
      await NotificationService.cancelNotification(event.reminderId.hashCode);

      // Remove from local list
      final updatedReminders = state.customReminders
          .where((reminder) => reminder.id != event.reminderId)
          .toList();

      // Save to storage
      await StorageService.saveCustomReminders(updatedReminders);

      emit(state.copyWith(
        customReminders: updatedReminders,
        status: WaterReminderStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleAutoReminder(
    ToggleAutoReminder event,
    Emitter<WaterReminderState> emit,
  ) async {
    try {
      await StorageService.setAutoReminderEnabled(event.enabled);

      DateTime? nextAutoTime;
      if (event.enabled) {
        await NotificationService.scheduleRepeatingNotification();
        nextAutoTime = DateTime.now().add(const Duration(hours: 2));
      } else {
        await NotificationService.cancelNotification(0); // Cancel auto reminder
      }

      emit(state.copyWith(
        isAutoReminderEnabled: event.enabled,
        nextAutoReminderTime: nextAutoTime,
        status: WaterReminderStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<WaterReminderState> emit,
  ) async {
    emit(state.copyWith(status: WaterReminderStatus.loading));

    try {
      final customReminders = await StorageService.getCustomReminders();

      emit(state.copyWith(
        status: WaterReminderStatus.success,
        customReminders: customReminders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onShowInstantNotification(
    ShowInstantNotification event,
    Emitter<WaterReminderState> emit,
  ) async {
    try {
      await NotificationService.showInstantNotification();
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
