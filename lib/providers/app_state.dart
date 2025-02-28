/*
Authors: Holden Vail
Description: This is file for managing global app states.
*/

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flavr/services/location_service.dart';
import 'package:flavr/screens/friends.dart';
import 'package:flavr/screens/home.dart';
import 'package:flavr/screens/profile.dart';
import 'package:flavr/screens/inbox.dart';

class AppState with ChangeNotifier {
  // Location Service Management
  Position? currentPosition;

  final locationService = LocationService();

  Future<void> updateCurrentLocation() async {
    try {
      currentPosition = await locationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // nav bar management
  bool useNavBar = true;
  void setUseNavBar(bool value) {
    useNavBar = value;
    notifyListeners();
  }

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List<Widget> screens = [
    HomeScreen(),
    const FriendsScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  Widget _currentScreen = HomeScreen();
  Widget get currentScreen => _currentScreen;

  void setCurrentScreen(Widget newScreen, int index) {
    _currentScreen = newScreen;
    _currentIndex = index;
    notifyListeners();
  }
}
