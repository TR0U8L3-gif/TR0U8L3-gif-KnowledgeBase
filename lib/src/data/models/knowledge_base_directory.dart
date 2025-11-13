import 'file_system_entity.dart';

class KnowledgeBaseDirectory extends FileSystemEntity {
  final List<FileSystemEntity> children;

  KnowledgeBaseDirectory({
    required super.title,
    required super.path,
    this.children = const [],
  });
}
