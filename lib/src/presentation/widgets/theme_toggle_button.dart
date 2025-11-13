import 'package:flutter/material.dart';
import 'package:knowledge_base/src/domain/state/app_state.dart';
import 'package:provider/provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return IconButton(
      icon: Icon(
        appState.themeMode == ThemeMode.light
            ? Icons.dark_mode
            : Icons.light_mode,
      ),
      onPressed: () {
        appState.toggleTheme();
      },
    );
  }
}
