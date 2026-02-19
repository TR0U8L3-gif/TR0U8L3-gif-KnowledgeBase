import '../entities/document_content.dart';
import '../entities/knowledge_base_item.dart';

/// Abstract repository defining operations for the knowledge base feature.
abstract class KnowledgeBaseRepository {
  /// Loads and parses the index.json file into a [DirectoryItem] tree.
  Future<DirectoryItem> loadIndex();

  /// Loads a markdown document from assets at the given [path].
  /// Returns a [DocumentContent] with parsed headings and raw markdown.
  Future<DocumentContent> loadDocument(String path);

  /// Returns a flat list of all [FileItem]s in the tree.
  List<FileItem> getAllFiles(DirectoryItem root);

  /// Computes breadcrumb labels from root to the item at [targetPath].
  List<BreadcrumbEntry> computeBreadcrumb(
    DirectoryItem root,
    String targetPath,
  );
}

/// Represents a single breadcrumb entry with a label and path.
class BreadcrumbEntry {
  final String label;
  final String path;
  final bool isFile;

  const BreadcrumbEntry({
    required this.label,
    required this.path,
    required this.isFile,
  });
}
