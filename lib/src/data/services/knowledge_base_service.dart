


import 'dart:core';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:knowledge_base/src/data/models/article.dart';
import 'package:knowledge_base/src/data/models/file_system_entity.dart';
import 'package:knowledge_base/src/data/models/knowledge_base_directory.dart';
import 'package:knowledge_base/src/data/models/toc_entry.dart';

class KnowledgeBaseService {
  Future<List<FileSystemEntity>> getTree() async {
    final manifest = await _getAssetManifest();
    return _parseTree(manifest, 'assets/knowledge_base');
  }

  Future<List<FileSystemEntity>> _parseTree(
      List<dynamic> items, String basePath) async {
    final entities = <FileSystemEntity>[];
    for (final item in items) {
      final name = item['name'] as String;
      final type = item['type'] as String;
      final currentPath = '$basePath/$name';

      if (type == 'directory') {
        final children = item['children'] as List<dynamic>? ?? [];
        entities.add(KnowledgeBaseDirectory(
          title: name,
          path: currentPath,
          children: await _parseTree(children, currentPath),
        ));
      } else if (type == 'file') {
        final content = await rootBundle.loadString(currentPath);
        final toc = _parseToc(content);
        entities.add(Article(
          title: name.replaceAll('.md', ''),
          path: currentPath,
          content: content,
          toc: toc,
        ));
      }
    }
    return entities;
  }

  List<TocEntry> _parseToc(String content) {
    final toc = <TocEntry>[];
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.startsWith('#')) {
        final level =
            line.codeUnits.takeWhile((char) => char == '#'.codeUnitAt(0)).length;
        final title = line.substring(level).trim();
        if (title.isNotEmpty) {
          final key = title.toLowerCase().replaceAll(' ', '-');
          toc.add(TocEntry(title: title, key: key, level: level));
        }
      }
    }
    return toc;
  }

  Future<List<dynamic>> _getAssetManifest() async {
    final manifestJson =
        await rootBundle.loadString('assets/asset_manifest.json');
    return json.decode(manifestJson) as List<dynamic>;
  }
}
