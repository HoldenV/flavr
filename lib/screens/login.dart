import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_state.dart';
import '../widgets/app_state_wrapper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AuthenticationState>(
          builder: (context, authState, child) {
            if (authState.user != null) {
              // Navigate to AppStateWrapper if user is signed in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const AppStateWrapper()),
                );
              });
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Image.asset(
                    'lib/assets/flavr-logo.png',
                    scale: 5), SizedBox(height: 40),
              GestureDetector(
                  onTap: () {
                    Provider.of<AuthenticationState>(context, listen: false)
                        .signInWithGoogle();
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
