import 'package:knowledge_base/src/data/models/file_system_entity.dart';
import 'package:knowledge_base/src/data/services/knowledge_base_service.dart';

class KnowledgeBaseRepository {
  final KnowledgeBaseService _knowledgeBaseService;

  List<FileSystemEntity>? _tree;

  KnowledgeBaseRepository(this._knowledgeBaseService);

  Future<List<FileSystemEntity>> getTree() async {
    _tree ??= await _knowledgeBaseService.getTree();
    return _tree!;
  }
}
