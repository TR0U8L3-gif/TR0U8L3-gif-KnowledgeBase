import 'package:flutter/material.dart';
import 'package:knowledge_base/src/data/models/article.dart';
import 'package:knowledge_base/src/data/models/file_system_entity.dart';
import 'package:knowledge_base/src/data/models/knowledge_base_directory.dart';
import 'package:knowledge_base/src/domain/repositories/knowledge_base_repository.dart';
import 'package:knowledge_base/src/domain/state/app_state.dart';
import 'package:provider/provider.dart';


class NavigationPanel extends StatelessWidget {
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<KnowledgeBaseRepository>(context);
    final appState = Provider.of<AppState>(context);

    return FutureBuilder<List<FileSystemEntity>>(
      future: repository.getTree(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No articles found.'));
        }

        final tree = snapshot.data!;
        final filteredTree = _filterTree(tree, appState.searchQuery);

        return ListView.builder(
          itemCount: filteredTree.length,
          itemBuilder: (context, index) {
            return _buildTile(context, filteredTree[index]);
          },
        );
      },
    );
  }

  List<FileSystemEntity> _filterTree(
      List<FileSystemEntity> tree, String query) {
    if (query.isEmpty) {
      return tree;
    }

    final filtered = <FileSystemEntity>[];
    for (final entity in tree) {
      if (entity.title.toLowerCase().contains(query.toLowerCase())) {
        filtered.add(entity);
      }
      if (entity is KnowledgeBaseDirectory) {
        final children = _filterTree(entity.children, query);
        if (children.isNotEmpty) {
          filtered.add(KnowledgeBaseDirectory(
            title: entity.title,
            path: entity.path,
            children: children,
          ));
        }
      }
    }
    return filtered;
  }

  Widget _buildTile(BuildContext context, FileSystemEntity entity) {
    if (entity is KnowledgeBaseDirectory) {
      return ExpansionTile(
        title: Text(entity.title),
        children: entity.children.map((e) => _buildTile(context, e)).toList(),
      );
    } else if (entity is Article) {
      return ListTile(
        title: Text(entity.title),
        onTap: () {
          Provider.of<AppState>(context, listen: false)
              .setSelectedArticle(entity);
        },
      );
    }
    return const SizedBox.shrink();
  }
}
