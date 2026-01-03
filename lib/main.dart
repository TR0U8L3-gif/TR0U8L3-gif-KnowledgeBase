import 'package:knowledge_base/src/knowledge_base/presentation/page/knowledge_base_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShadcnApp(
      theme: ThemeData(colorScheme: ColorSchemes.darkDefaultColor, radius: 0.5),
      home: KnowledgeBasePage(),
    );
  }
}
