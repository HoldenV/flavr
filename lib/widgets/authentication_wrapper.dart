/*
This is where we'll define the AuthenticationWrapper widget.
*/

// Dependency imports
import 'package:flavr/providers/authentication_state.dart';
import 'package:flavr/widgets/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screen imports
import '../screens/login_screen.dart';

// Same as our MyApp widget, we're extending this from a stateless widget.
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from Authentication State.
    final user = Provider.of<AuthenticationState>(context).user;
    if (user == null) {
      // If they're insn't a user logged in, direct them to the login screen.
      return const LoginScreen();
    } else {
      // If someone is logged in, continue initializing the app.
      return const AppStateWrapper();
    }
  }
}
