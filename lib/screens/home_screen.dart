import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/water_reminder_bloc.dart';
import '../bloc/water_reminder_event.dart';
import '../bloc/water_reminder_state.dart';
import '../widgets/next_reinder_card.dart';
import '../widgets/action_buttons.dart';
import './calender_screen.dart';
import 'reminders_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💧 Water Reminder'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemindersListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<WaterReminderBloc, WaterReminderState>(
        listener: (context, state) {
          if (state.status == WaterReminderStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == WaterReminderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Hydration Icon
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),

                // Welcome Message
                Text(
                  'Stay Hydrated!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep track of your water intake',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 32),

                // Next Reminder Card
                NextReminderCard(
                  isAutoEnabled: state.isAutoReminderEnabled,
                  nextAutoTime: state.nextAutoReminderTime,
                  nextCustomReminder: state.customReminders.isNotEmpty
                      ? state.customReminders
                          .where((r) => r.dateTime.isAfter(DateTime.now()))
                          .fold<DateTime?>(
                              null,
                              (earliest, reminder) => earliest == null ||
                                      reminder.dateTime.isBefore(earliest)
                                  ? reminder.dateTime
                                  : earliest)
                      : null,
                ),
                const SizedBox(height: 32),

                // Action Buttons
                ActionButtons(
                  isAutoEnabled: state.isAutoReminderEnabled,
                  onToggleAuto: (enabled) {
                    context
                        .read<WaterReminderBloc>()
                        .add(ToggleAutoReminder(enabled));
                  },
                  onAddCustom: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarScreen(),
                      ),
                    );
                  },
                  onTestNotification: () {
                    context
                        .read<WaterReminderBloc>()
                        .add(ShowInstantNotification());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
