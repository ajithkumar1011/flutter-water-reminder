import 'dart:math';

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
    emit(state.copyWith(
      status: WaterReminderStatus.loading,
      consoleError: e,
    ));

    try {
      final customReminders = await StorageService.getCustomReminders();
      final isAutoEnabled = await StorageService.isAutoReminderEnabled();

      DateTime? nextAutoTime;
      if (isAutoEnabled) {
        await NotificationService.scheduleAutoReminder();

        nextAutoTime = DateTime.now().add(const Duration(hours: 2));
      }

      emit(state.copyWith(
        status: WaterReminderStatus.success,
        customReminders: customReminders,
        isAutoReminderEnabled: isAutoEnabled,
        nextAutoReminderTime: nextAutoTime,
        consoleError: e,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
        consoleError: e,
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
        consoleError: e,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
        consoleError: e,
      ));
    }
  }

  Future<void> _onDeleteCustomReminder(
    DeleteCustomReminder event,
    Emitter<WaterReminderState> emit,
  ) async {
    try {
      // Cancel the notification
      await NotificationService.cancelAutoReminder();

      // Remove from local list
      final updatedReminders = state.customReminders
          .where((reminder) => reminder.id != event.reminderId)
          .toList();

      // Save to storage
      await StorageService.saveCustomReminders(updatedReminders);

      emit(state.copyWith(
        customReminders: updatedReminders,
        status: WaterReminderStatus.success,
        consoleError: e,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
        consoleError: e,
      ));
    }
  }

  Future<void> _onToggleAutoReminder(
    ToggleAutoReminder event,
    Emitter<WaterReminderState> emit,
  ) async {
    try {
      if (event.enabled) {
        await NotificationService.requestPermissions();
        await NotificationService.scheduleAutoReminder();
      } else {
        await NotificationService.cancelAutoReminder();
      }

      await StorageService.setAutoReminderEnabled(event.enabled);

      emit(state.copyWith(
        isAutoReminderEnabled: event.enabled,
        nextAutoReminderTime:
            event.enabled ? DateTime.now().add(const Duration(hours: 2)) : null,
        status: WaterReminderStatus.success,
        consoleError: e,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
        consoleError: e,
      ));
    }
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<WaterReminderState> emit,
  ) async {
    emit(state.copyWith(
      status: WaterReminderStatus.loading,
      consoleError: e,
    ));

    try {
      final customReminders = await StorageService.getCustomReminders();

      emit(state.copyWith(
        status: WaterReminderStatus.success,
        customReminders: customReminders,
        consoleError: e,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterReminderStatus.error,
        errorMessage: e.toString(),
        consoleError: e,
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
        consoleError: e,
      ));
    }
  }
}
