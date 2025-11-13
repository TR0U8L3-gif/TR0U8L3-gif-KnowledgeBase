import 'package:flutter/material.dart';
import 'package:knowledge_base/src/domain/state/app_state.dart';
import 'package:provider/provider.dart';

class TocPanel extends StatelessWidget {
  const TocPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.selectedArticle == null ||
            appState.selectedArticle!.toc.isEmpty) {
          return const Center(
            child: Text('No table of contents.'),
          );
        }
        return ListView.builder(
          itemCount: appState.selectedArticle!.toc.length,
          itemBuilder: (context, index) {
            final entry = appState.selectedArticle!.toc[index];
            return ListTile(
              title: Text(entry.title),
              contentPadding: EdgeInsets.only(left: entry.level * 16.0),
            );
          },
        );
      },
    );
  }
}
