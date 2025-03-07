/*
Authors: Holden Vail
Description: This is the main file for flavr's flutter UI
*/

// Dependency imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';


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

  // Portrait lock app before initialization
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flavr',
      theme: ThemeData(
        // Set all relevant theme data here
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(),
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        primaryColor: Colors.orange,
        splashFactory:
            NoSplash.splashFactory, // Disables annoying ripple effect
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}
