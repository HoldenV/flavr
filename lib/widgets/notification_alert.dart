import 'package:flutter/material.dart';

class NotificationOverlay extends StatelessWidget {
  final String notificationContent;
  final VoidCallback onClose;

  const NotificationOverlay({
    super.key,
    required this.notificationContent,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black54,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notification',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(notificationContent),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: onClose,
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
