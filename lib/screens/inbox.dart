import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_alert.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  InboxScreenState createState() => InboxScreenState();
}

class InboxScreenState extends State<InboxScreen> {
  String? _selectedNotification;

  void _showNotificationOverlay(String notificationContent) {
    setState(() {
      _selectedNotification = notificationContent;
    });
  }

  void _closeNotificationOverlay() {
    setState(() {
      _selectedNotification = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Inbox',
              style: GoogleFonts.oi(),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, child) {
              if (notificationsProvider.notifications.isEmpty) {
                return const Center(
                  child: Text(
                    'No new notifications!',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: notificationsProvider.notifications.length,
                  itemBuilder: (context, index) {
                    String notification =
                        notificationsProvider.notifications[index];
                    String firstLine = notification.split('\n').first;
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(
                          firstLine,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Tap to view details',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () => _showNotificationOverlay(notification),
                      ),
                    );
                  },
                );
              }
            },
          ),
          if (_selectedNotification != null)
            NotificationOverlay(
              notificationContent: _selectedNotification!,
              onClose: _closeNotificationOverlay,
            ),
        ],
      ),
    );
  }
}
