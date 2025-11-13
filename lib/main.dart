import 'package:flutter/material.dart';
import 'package:knowledge_base/src/data/services/knowledge_base_service.dart';
import 'package:knowledge_base/src/domain/repositories/knowledge_base_repository.dart';
import 'package:knowledge_base/src/domain/state/app_state.dart';
import 'package:knowledge_base/src/presentation/screens/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => KnowledgeBaseService(),
        ),
        ProxyProvider<KnowledgeBaseService, KnowledgeBaseRepository>(
          update: (context, service, previous) =>
              KnowledgeBaseRepository(service),
        ),
        ChangeNotifierProvider(
          create: (context) => AppState(),
        ),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Knowledge Base',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: appState.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
