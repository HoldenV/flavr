import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_state.dart';
import '../providers/app_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer2<AuthenticationState, AppState>(
          builder: (context, authState, appState, child) {
            if (authState.user != null) {
              // Check if the username is 'null_username' and navigate accordingly
              appState.checkUsernameAndNavigate(context, authState);
            }
            return ElevatedButton(
              onPressed: () {
                Provider.of<AuthenticationState>(context, listen: false)
                    .signInWithGoogle();
              },
              child: const Text('Sign in with Google'),
            );
          },
        ),
      ),
    );
  }
}
