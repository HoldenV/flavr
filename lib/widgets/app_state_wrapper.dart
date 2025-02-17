/*
This is file is for providing the AppStateWrapper widget.
 */

// Dependency Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Provider Imports
import 'package:flavr/providers/app_state.dart';

// Screen Imports
import 'package:flavr/screens/home_screen.dart';

class AppStateWrapper extends StatelessWidget {
  const AppStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          appState.updateCurrentLocation();
          if (appState.currentPosition != null) {
            return const HomeScreen();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
