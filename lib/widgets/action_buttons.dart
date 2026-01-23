import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool isAutoEnabled;
  final Function(bool) onToggleAuto;
  final VoidCallback onAddCustom;
  final VoidCallback onTestNotification;

  const ActionButtons({
    super.key,
    required this.isAutoEnabled,
    required this.onToggleAuto,
    required this.onAddCustom,
    required this.onTestNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle Auto Reminder Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => onToggleAuto(!isAutoEnabled),
            icon: Icon(
              isAutoEnabled ? Icons.toggle_on : Icons.toggle_off,
              size: 24,
            ),
            label: Text(
              isAutoEnabled ? 'Disable Auto Reminder' : 'Enable Auto Reminder',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAutoEnabled ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Add Custom Reminder Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onAddCustom,
            icon: const Icon(Icons.add_alarm, size: 24),
            label: const Text(
              'Add Custom Reminder',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Test Notification Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: onTestNotification,
            icon: const Icon(Icons.notifications_active, size: 24),
            label: const Text(
              'Test Notification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
