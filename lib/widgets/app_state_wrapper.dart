import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavr/providers/app_state.dart';
import 'app_frame.dart';

class AppStateWrapper extends StatelessWidget {
  const AppStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const AppFrame(),
    );
  }
}
