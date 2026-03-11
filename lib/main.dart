import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/core/shared/app_bloc_observer.dart';
import 'package:knowledge_base/core/shared/app_logger.dart';
import 'package:knowledge_base/core/shared/logging/web_console_stub.dart'
    if (dart.library.js_interop) 'package:knowledge_base/core/shared/logging/web_console.dart';
import 'package:knowledge_base/src/knowledge_base/data/data_sources/favorites_local_data_source.dart';
import 'package:knowledge_base/src/knowledge_base/data/data_sources/knowledge_base_local_data_source.dart';
import 'package:knowledge_base/src/knowledge_base/data/repositories/favorites_repository_impl.dart';
import 'package:knowledge_base/src/knowledge_base/data/repositories/knowledge_base_repository_impl.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/favorites_repository.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/knowledge_base_repository.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/favorites/favorites_cubit.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_cubit.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/pages/knowledge_base_page.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  registerDebugCommands();

  Bloc.observer = const AppBlocObserver();

  FlutterError.onError = (details) {
    AppLogger.error(
      details.exceptionAsString(),
      name: 'FlutterError',
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      error.toString(),
      name: 'PlatformDispatcher',
      error: error,
      stackTrace: stack,
    );
    return false;
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<KnowledgeBaseRepository>(
          create: (_) => KnowledgeBaseRepositoryImpl(
            dataSource: KnowledgeBaseLocalDataSource(),
          ),
        ),
        Provider<FavoritesRepository>(
          create: (_) =>
              FavoritesRepositoryImpl(dataSource: FavoritesLocalDataSource()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final repository = context.read<KnowledgeBaseRepository>();
          final favoritesRepository = context.read<FavoritesRepository>();
          return MultiBlocProvider(
            providers: [
              BlocProvider<NavigationBloc>(
                create: (_) =>
                    NavigationBloc(repository: repository)
                      ..add(const LoadIndex()),
              ),
              BlocProvider<DocumentBloc>(
                create: (_) => DocumentBloc(repository: repository),
              ),
              BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
              BlocProvider<FavoritesCubit>(
                create: (_) => FavoritesCubit(repository: favoritesRepository),
              ),
            ],
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                final brightness = MediaQuery.platformBrightnessOf(context);
                final isDark = switch (themeState.themeMode) {
                  ThemeMode.system => brightness == Brightness.dark,
                  ThemeMode.dark => true,
                  ThemeMode.light => false,
                };

                return ShadcnApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    colorScheme: isDark
                        ? ColorSchemes.darkZinc
                        : ColorSchemes.lightZinc,
                    radius: 0.5,
                  ),
                  popoverHandler: const PopoverOverlayHandler(),
                  menuHandler: const PopoverOverlayHandler(),
                  home: const KnowledgeBasePage(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
