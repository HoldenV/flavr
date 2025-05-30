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
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/assets/flavr-logo.png', scale: 5),
                  SizedBox(height: 40),
                  GestureDetector(
                      onTap: () {
                        Provider.of<AuthenticationState>(context, listen: false)
                            .signInWithGoogle(context);
                      },
                      child: Image.asset(
                        'lib/assets/continue_with_google.png',
                        scale: 4,
                      ))
                ]);
          },
        ),
      ),
    );
  }
}
