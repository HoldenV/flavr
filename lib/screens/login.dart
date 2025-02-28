import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_state.dart';
import 'home.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AuthenticationState>(
          builder: (context, authState, child) {
            if (authState.user != null) {
              // Navigate to home screen if user is signed in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              });
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
