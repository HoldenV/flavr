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

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthenticationState>(context);
    final user = authState.user;

    if (user == null) {
      return const LoginScreen();
    } else {
      // Check username and navigate accordingly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authState.checkUsernameAndNavigate(context, authState);
      });
      return const AppStateWrapper();
    }
  }
}
