import 'package:flutter/material.dart';
import 'package:knowledge_base/src/presentation/widgets/article_panel.dart';
import 'package:knowledge_base/src/presentation/widgets/navigation_panel.dart';
import 'package:knowledge_base/src/presentation/widgets/theme_toggle_button.dart';
import 'package:knowledge_base/src/presentation/widgets/toc_panel.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Column(
        children: [
          const SearchBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const NavigationPanel(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Theme.of(context).colorScheme.surface,
                    child: const ArticlePanel(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const TocPanel(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
