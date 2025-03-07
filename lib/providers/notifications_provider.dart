import 'package:flutter/foundation.dart';

class NotificationsProvider extends ChangeNotifier {
  List<String> _notifications = [];

  List<String> get notifications => _notifications;

  void addNotification(String notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  void removeNotification(String notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void addDefaultNotifications() {
    _notifications.addAll([
      '🎉 Welcome to Flavr! 🎉\nWe\'re thrilled to have you here! Get ready to embark on a delicious journey to discover amazing food. Swipe right to find your next favorite dish, and swipe left to pass. Bon appétit!\n🍔 🍕 🍣 🍜 🍰',
      '🍔 New Burger Joint in Town!\nCheck out the latest burger joint that just opened up in your area. Don\'t miss out on their special offers!',
      '🍕 Pizza Night!\nIt\'s pizza night! Order your favorite pizza now and enjoy a cozy night in with delicious slices.',
    ]);
    notifyListeners();
  }
}
