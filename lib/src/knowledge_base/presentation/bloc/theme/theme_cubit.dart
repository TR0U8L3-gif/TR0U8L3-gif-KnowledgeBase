import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'theme_state.dart';

/// Manages the app theme mode (system, light, dark).
///
/// Defaults to [ThemeMode.system] so the app respects the OS preference
/// on first launch. The user can override it via the header dropdown.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

  void setThemeMode(ThemeMode? mode) {
    if (mode == null) return;
    emit(state.copyWith(themeMode: mode));
  }
}
