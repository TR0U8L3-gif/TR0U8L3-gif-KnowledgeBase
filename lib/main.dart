import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/data/data_sources/knowledge_base_local_data_source.dart';
import 'package:knowledge_base/src/knowledge_base/data/repositories/knowledge_base_repository_impl.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/knowledge_base_repository.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_cubit.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/pages/knowledge_base_page.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<KnowledgeBaseRepository>(
      create: (_) => KnowledgeBaseRepositoryImpl(
        dataSource: KnowledgeBaseLocalDataSource(),
      ),
      child: Builder(
        builder: (context) {
          final repository = context.read<KnowledgeBaseRepository>();
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
                        ? ColorSchemes.darkDefaultColor
                        : ColorSchemes.lightDefaultColor,
                    radius: 0.5,
                  ),
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
