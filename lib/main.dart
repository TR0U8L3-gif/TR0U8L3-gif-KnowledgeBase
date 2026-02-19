import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/data/data_sources/knowledge_base_local_data_source.dart';
import 'package:knowledge_base/src/knowledge_base/data/repositories/knowledge_base_repository_impl.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/knowledge_base_repository.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
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
            ],
            child: const ShadcnApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorSchemes.darkDefaultColor,
                radius: 0.5,
              ),
              home: KnowledgeBasePage(),
            ),
          );
        },
      ),
    );
  }
}
