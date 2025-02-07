/*
This is where we'll define an AuthWrapper widget.
*/

// Dependency imports
import 'package:flavr/providers/authentication_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screen imports
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

// Same as our MyApp widget, we're extending this from a stateless widget and
// using const since it will only have one instance and it improves performance.
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationState>(context).user;
    if (user == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}
