import 'dart:convert';

import 'package:flutter/services.dart';

/// Local data source that reads files from Flutter assets.
class KnowledgeBaseLocalDataSource {
  /// Loads and parses the index.json asset file.
  Future<Map<String, dynamic>> loadIndexJson() async {
    final jsonString = await rootBundle.loadString('assets/data/index.json');
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Loads a markdown file from the assets/data/ directory.
  ///
  /// [path] is relative to assets/data/, e.g. "api/auth.md".
  Future<String> loadMarkdownFile(String path) async {
    return rootBundle.loadString('assets/data/$path');
  }
}
