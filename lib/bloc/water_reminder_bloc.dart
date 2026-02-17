import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'water_reminder_event.dart';
import 'water_reminder_state.dart';

class WaterReminderBloc extends Bloc<WaterReminderEvent, WaterReminderState> {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
      
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
    ));

    try {
      final customReminders = await StorageService.getCustomReminders();
      final isAutoEnabled = await StorageService.isAutoReminderEnabled();

      // Load the persisted auto reminder scheduled time
      DateTime? nextAutoTime;
      if (isAutoEnabled) {
        nextAutoTime = await StorageService.getAutoReminderScheduledTime();
        
        // If we have a stored time, use it to reschedule
        // (in case the notification was cleared or device restarted)
        if (nextAutoTime != null && nextAutoTime.isAfter(DateTime.now())) {
          // Reschedule with the same time
          await NotificationService.scheduleAutoReminder(
            scheduledTime: nextAutoTime,
          );
        } else {
          // If no time stored or time is past, schedule a new one
          nextAutoTime = DateTime.now().add(const Duration(hours: 2));
          await NotificationService.scheduleAutoReminder(
            scheduledTime: nextAutoTime,
          );
          await StorageService.setAutoReminderScheduledTime(nextAutoTime);
        }
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
      // ✅ Request permissions FIRST before scheduling
      await NotificationService.requestPermissions();
      
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
        errorMessage: 'Failed to set reminder. Please ensure notification permissions are granted.',
      ));
    }
  }

  Future<void> _onDeleteCustomReminder(
    DeleteCustomReminder event,
    Emitter<WaterReminderState> emit,
  ) async {
    try {
      // Find the reminder to get its ID for cancellation
      final reminderToDelete = state.customReminders
          .firstWhere((reminder) => reminder.id == event.reminderId);
      
      // Cancel the specific notification using the reminder's ID
      await _notifications.cancel(reminderToDelete.id.hashCode);

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
      DateTime? nextAutoTime;
      
      if (event.enabled) {
        await NotificationService.requestPermissions();
        
        // Calculate and persist the scheduled time
        nextAutoTime = DateTime.now().add(const Duration(hours: 2));
        await NotificationService.scheduleAutoReminder(
          scheduledTime: nextAutoTime,
        );
        await StorageService.setAutoReminderScheduledTime(nextAutoTime);
      } else {
        await NotificationService.cancelAutoReminder();
        // Clear the stored time when disabled
        await StorageService.setAutoReminderScheduledTime(null);
      }

      await StorageService.setAutoReminderEnabled(event.enabled);

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
    emit(state.copyWith(
      status: WaterReminderStatus.loading,
    ));

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
