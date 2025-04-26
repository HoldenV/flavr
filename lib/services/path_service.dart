
import 'dart:math';

import 'package:flutter/services.dart';

nameToPath(String foodName) {
  String path = foodName.toLowerCase().replaceAll(' ', '-');
  path = 'lib/assets/dish_images/$path.jpg';
  return path;
}

pathToName(String path) {
  String foodName = path
      .substring(23, path.length - 4)
      .replaceAll('lib/assets/dish_images/', '')
      .replaceAll('-', ' ');
  if (foodName == 'shabu shabu') {
    foodName = 'shabu-shabu';
  }
  return foodName;
}
// Helper method to capitalize the first char of a string
  // Redefined here because I don't want to find where global functions are defined LOL
  // If you know, place this and the one in app_state.dart there
extension StringExtensions on String { 
  String capitalize() { 
    return '${this[0].toUpperCase()}${substring(1)}'; 
  } 
}

pathToNameCaps(String path) {
  String foodName = path
      .substring(23, path.length - 4)
      .replaceAll('lib/assets/dish_images/', '')
      .replaceAll('-', ' ');
  if (foodName == 'shabu shabu') {
    foodName = 'Shabu-Shabu';
  }
  return foodName.split(' ').map((word) => word.capitalize()).join(' ');
}

Future<String> numToFood(int number) async {
  try {
    String content = await rootBundle.loadString('lib/data/foods.csv');
    List<String> lines = content.split('\n');
    return lines[number].trim();
  } catch (e) {
    print('Error reading file: $e');
    return ''; // Return an empty string or handle as appropriate
  }
}

generateFoodPath() async {
  var random = Random();
  String foodName = await numToFood(random.nextInt(132));
  return nameToPath(foodName);
}

Future<String> loadCsv() async {
  return await rootBundle.loadString('lib/data/foods.csv');
}
