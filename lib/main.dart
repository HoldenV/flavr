/*
Authors: Holden Vail
Description: This is the main file for flavr's flutter UI
*/

// Dependency imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Widget imports
import 'widgets/authentication_wrapper.dart';

// Provider imports
import 'providers/app_state.dart';
import 'providers/authentication_state.dart';

void main() async {
  // Ensures the flutter framework is properly initialized first
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Here we're telling our root widget that it should use these providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => AuthenticationState()),
      ],
      // The root widget will be an instance of MyApp()
      child: const MyApp(),
    ),
  );
}

// Here we're extending MyApp from a stateless widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  // We're overriding the build method of MyApp to instead build a material3 app
  // widget. This is also where we can set the theme data and home widget.
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flavr',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
        ),
      ),
      // Here we're setting the home widget to our Authentication Wrapper Widget.
      home: const AuthenticationWrapper(),
    );
  }
}
