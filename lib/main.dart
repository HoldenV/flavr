/*
Authors: Holden Vail
Description: This is the main file for flavr's flutter UI
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/app_state.dart';

void main() {
  // The runApp function takes a widget and makes it the root of the widget tree.
  // Here, we are istantiating and wrapping a ChangeNotifierProvider object around an instance
  // we're of the AppState class that we're instantiating.
  runApp(
    ChangeNotifierProvider(
      // The create function is called to create an instance of AppState.
      create: (context) => AppState(),
      // The child parameter is the widget that will be the root of the widget tree.
      // In this case, it is the MyApp widget.
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flavr',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
