import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:knowledge_base/src/domain/state/app_state.dart';
import 'package:provider/provider.dart';

class ArticlePanel extends StatelessWidget {
  const ArticlePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.selectedArticle == null) {
          return const Center(
            child: Text('Select an article to read.'),
          );
        }
        return Markdown(
          data: appState.selectedArticle!.content,
          controller: ScrollController(),
        );
      },
    );
  }
}
