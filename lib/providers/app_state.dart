/*
Authors: Holden Vail
Description: This is file for managing global app states.
*/

import 'package:flavr/services/model_connect.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flavr/services/location_service.dart';
import 'package:flavr/screens/friends.dart';
import 'package:flavr/screens/home.dart';
import 'package:flavr/screens/profile.dart';
import 'package:flavr/screens/inbox.dart';
import 'package:flavr/services/path_service.dart';
import 'package:flavr/providers/authentication_state.dart';

class AppState with ChangeNotifier {
  final AuthenticationState authState;

  AppState({required this.authState});

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

  List<String> positiveSwipes = [];
  List<String> negativeSwipes = [];

  void positiveSwipe(String foodName) {
    positiveSwipes.add(foodName);
    notifyListeners();
  }

  void negativeSwipe(String foodName) {
    negativeSwipes.add(foodName);
    notifyListeners();
  }

  void resetSession() {
    swipeCount = 0;
    positiveSwipes = [];
    negativeSwipes = [];
    currentRecommendation = '';
    currentRestaurants = [];
    notifyListeners();
  }

  List<String> imagePaths = [];

  void addCard(String path) {
    imagePaths.add(path);
    notifyListeners();
  }

  String currentRecommendation = '';
  List<dynamic> currentRestaurants = [];

  dynamic currentUserId;

  void setRecommendation(String recommendation) {
    currentRecommendation = recommendation;
    notifyListeners();
  }

  Future<String> getRecommendation() async {
    notifyListeners();
    String assembledString = '{"user-id": "${authState.user?.uid}", "swipes": {';
    for (String dish in positiveSwipes) {
      assembledString += '"$dish": 1,';
    }
    for (String dish in negativeSwipes) {
      assembledString += '"$dish": -1,';
    }
    if (assembledString.endsWith(',')) {
      assembledString = '${assembledString.substring(0, assembledString.length - 1)}}}';
    }
    print(assembledString);
    final recFood = await swipesToRec(data: assembledString);
    return recFood;
  }

  void updateRestaurants(List<dynamic> restaurantData) {
    if (restaurantData.length >= 3) {
      currentRestaurants = restaurantData;
      notifyListeners();
    }
  }
}
