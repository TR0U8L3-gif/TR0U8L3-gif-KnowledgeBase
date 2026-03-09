import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/core/shared/app_logger.dart';

/// Global [BlocObserver] that routes all BLoC/Cubit errors and transitions
/// to [AppLogger], making them visible in the Chrome DevTools Console tab
/// when running on Flutter web (including GitHub Pages).
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      '${bloc.runtimeType} threw an error',
      name: '${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    AppLogger.debug(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} → '
      '${change.nextState.runtimeType}',
      name: '${bloc.runtimeType}',
    );
    super.onChange(bloc, change);
  }
}
