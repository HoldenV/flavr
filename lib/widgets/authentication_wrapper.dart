/*
This is where we'll define the AuthenticationWrapper widget.
*/

// Dependency imports
import 'package:flavr/providers/authentication_state.dart';
import 'package:flavr/widgets/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screen imports
import '../screens/login.dart';
import '../screens/splash.dart'; // Import the splash screen

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthenticationState>(context);
    final user = authState.user;

    if (authState.loading) {
      // Show splash screen while loading
      return SplashScreen();
    }

    if (user == null) {
      // Direct to login screen if no user is signed in
      return const LoginScreen();
    } else {
      // Direct to app if user is logged in
      return const AppStateWrapper();
    }
  }
}
