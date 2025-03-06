import 'package:flutter/material.dart';
import 'package:flavr/widgets/navigation_bar.dart';
import 'package:flavr/providers/app_state.dart';
import 'package:provider/provider.dart';

class AppFrame extends StatelessWidget {
  const AppFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: appState.currentScreen,
          ),
          bottomNavigationBar: useBottomNavigationBar(context),
        );
      },
    );
  }
}
