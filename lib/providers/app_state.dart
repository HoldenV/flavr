/*
Authors: Holden Vail
Description: This is file for managing global app states.
*/

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flavr/services/location_service.dart';

class AppState with ChangeNotifier {
  Position? _currentPosition;
  final LocationService _locationService = LocationService();

  Position? get currentPosition => _currentPosition;

  Future<void> updateCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      // Handle the error appropriately in your app
      print('Error getting location: $e');
    }
  }
}
