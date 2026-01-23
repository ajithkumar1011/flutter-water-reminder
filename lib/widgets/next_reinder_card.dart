import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextReminderCard extends StatelessWidget {
  final bool isAutoEnabled;
  final DateTime? nextAutoTime;
  final DateTime? nextCustomReminder;

  const NextReminderCard({
    super.key,
    required this.isAutoEnabled,
    this.nextAutoTime,
    this.nextCustomReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Next Reminder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isAutoEnabled && nextCustomReminder == null)
              _buildNoRemindersWidget(context)
            else
              _buildNextReminderInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRemindersWidget(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.schedule_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          'No reminders active',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enable auto reminders or add a custom reminder',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNextReminderInfo(BuildContext context) {
    DateTime? earliestReminder;
    String reminderType = '';

    // Determine the earliest upcoming reminder
    if (isAutoEnabled && nextAutoTime != null) {
      if (nextCustomReminder == null ||
          nextAutoTime!.isBefore(nextCustomReminder!)) {
        earliestReminder = nextAutoTime;
        reminderType = 'Auto Reminder';
      } else {
        earliestReminder = nextCustomReminder;
        reminderType = 'Custom Reminder';
      }
    } else if (nextCustomReminder != null) {
      earliestReminder = nextCustomReminder;
      reminderType = 'Custom Reminder';
    }

    if (earliestReminder == null) {
      return _buildNoRemindersWidget(context);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            reminderType,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          DateFormat('MMM dd, yyyy').format(earliestReminder),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('hh:mm a').format(earliestReminder),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue.shade600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _getTimeUntilReminder(earliestReminder),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getTimeUntilReminder(DateTime reminderTime) {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);

    if (difference.isNegative) {
      return 'Past due';
    }

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
}
