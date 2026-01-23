import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/water_reminder_bloc.dart';
import '../bloc/water_reminder_event.dart';
import '../bloc/water_reminder_state.dart';
import '../models/reminder_model.dart';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WaterReminderBloc>().add(LoadReminders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 All Reminders'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: BlocBuilder<WaterReminderBloc, WaterReminderState>(
        builder: (context, state) {
          if (state.status == WaterReminderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingReminders = state.customReminders
              .where((reminder) => reminder.dateTime.isAfter(DateTime.now()))
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Auto Reminder Status
                Card(
                  elevation: 2,
                  color: state.isAutoReminderEnabled
                      ? Colors.green.shade50
                      : Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: state.isAutoReminderEnabled
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto Reminder (Every 2 Hours)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                state.isAutoReminderEnabled
                                    ? 'Active'
                                    : 'Disabled',
                                style: TextStyle(
                                  color: state.isAutoReminderEnabled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              if (state.isAutoReminderEnabled &&
                                  state.nextAutoReminderTime != null)
                                Text(
                                  'Next: ${DateFormat('MMM dd, yyyy - hh:mm a').format(state.nextAutoReminderTime!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Custom Reminders Section
                Text(
                  'Custom Reminders (${upcomingReminders.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Custom Reminders List
                Expanded(
                  child: upcomingReminders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No custom reminders set',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add a custom reminder from the home screen',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: upcomingReminders.length,
                          itemBuilder: (context, index) {
                            final reminder = upcomingReminders[index];
                            return _buildReminderCard(context, reminder);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel reminder) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.water_drop,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a')
                        .format(reminder.dateTime),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _getTimeUntilReminder(reminder.dateTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, reminder),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeUntilReminder(DateTime reminderTime) {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Very soon';
    }
  }

  void _showDeleteConfirmation(BuildContext context, ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: Text(
            'Are you sure you want to delete this reminder?\n\n${DateFormat('MMM dd, yyyy - hh:mm a').format(reminder.dateTime)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<WaterReminderBloc>()
                    .add(DeleteCustomReminder(reminder.id));
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
