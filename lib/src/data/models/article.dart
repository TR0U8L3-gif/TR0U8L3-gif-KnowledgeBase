

import 'package:knowledge_base/src/data/models/file_system_entity.dart';
import 'package:knowledge_base/src/data/models/toc_entry.dart';

class Article extends FileSystemEntity {
  final String content;
  final List<TocEntry> toc;

  Article({
    required super.title,
    required super.path,
    required this.content,
    this.toc = const [],
  });
}
