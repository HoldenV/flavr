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
import 'package:flavr/screens/account_creation.dart';
import 'package:flavr/providers/authentication_state.dart';
import 'package:flavr/widgets/app_state_wrapper.dart';

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
    FriendsScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  Widget _currentScreen = HomeScreen();
  Widget get currentScreen => _currentScreen;

  void setCurrentScreen(Widget newScreen, int index) {
    _currentScreen = newScreen;
    _currentIndex = index;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    _currentScreen = screens[index];
    notifyListeners();
  }

  void incrementSwipeCount() {
    swipeCount++;
    notifyListeners();
  }

  void resetSwipeCount() {
    swipeCount = 0;
    notifyListeners();
  }

  int swipeCount = 0;

  // Method to check username and navigate to AccountCreationScreen if needed
  Future<void> checkUsernameAndNavigate(
      BuildContext context, AuthenticationState authState) async {
    if (authState.userModel?.username == 'null_username') {
      // Navigate to AccountCreationScreen if username is 'null_username'
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AccountCreationScreen()),
        );
      });
    } else {
      // Navigate to AppStateWrapper if user is signed in and username is valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AppStateWrapper()),
        );
      });
    }
  }
}
