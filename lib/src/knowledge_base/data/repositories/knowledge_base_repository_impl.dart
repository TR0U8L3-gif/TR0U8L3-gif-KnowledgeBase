import '../../domain/entities/document_content.dart';
import '../../domain/entities/knowledge_base_item.dart';
import '../../domain/repositories/knowledge_base_repository.dart';
import '../data_sources/knowledge_base_local_data_source.dart';
import '../models/knowledge_base_item_model.dart';

/// Concrete implementation of [KnowledgeBaseRepository].
///
/// Reads data from local Flutter assets via [KnowledgeBaseLocalDataSource].
class KnowledgeBaseRepositoryImpl implements KnowledgeBaseRepository {
  final KnowledgeBaseLocalDataSource _dataSource;

  KnowledgeBaseRepositoryImpl({
    required KnowledgeBaseLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<DirectoryItem> loadIndex() async {
    final json = await _dataSource.loadIndexJson();
    final directory = json['directory'] as Map<String, dynamic>;
    return KnowledgeBaseItemModel.fromJson(directory) as DirectoryItem;
  }

  @override
  Future<DocumentContent> loadDocument(String path) async {
    final markdown = await _dataSource.loadMarkdownFile(path);
    final stripped = _stripFrontmatter(markdown);
    final headings = _extractHeadings(stripped);

    return DocumentContent(rawMarkdown: stripped, headings: headings);
  }

  @override
  List<FileItem> getAllFiles(DirectoryItem root) {
    final files = <FileItem>[];
    _collectFiles(root, files);
    return files;
  }

  @override
  List<BreadcrumbEntry> computeBreadcrumb(
    DirectoryItem root,
    String targetPath,
  ) {
    final result = <BreadcrumbEntry>[];
    _findBreadcrumb(root, targetPath, result);
    return result;
  }

  // ── Private helpers ──────────────────────────────────────────────────

  void _collectFiles(KnowledgeBaseItem item, List<FileItem> files) {
    if (item is FileItem) {
      files.add(item);
    } else if (item is DirectoryItem) {
      for (final child in item.sortedItems) {
        _collectFiles(child, files);
      }
    }
  }

  bool _findBreadcrumb(
    KnowledgeBaseItem item,
    String targetPath,
    List<BreadcrumbEntry> result,
  ) {
    // Target is this directory itself
    if (item is DirectoryItem && item.path == targetPath) {
      result.add(
        BreadcrumbEntry(label: item.name, path: item.path, isFile: false),
      );
      return true;
    }

    if (item is FileItem && item.path == targetPath) {
      result.add(
        BreadcrumbEntry(label: item.name, path: item.path, isFile: true),
      );
      return true;
    }

    if (item is DirectoryItem) {
      for (final child in item.sortedItems) {
        if (_findBreadcrumb(child, targetPath, result)) {
          result.insert(
            0,
            BreadcrumbEntry(label: item.name, path: item.path, isFile: false),
          );
          return true;
        }
      }
    }

    return false;
  }

  /// Strips YAML frontmatter (between --- delimiters) from markdown.
  String _stripFrontmatter(String markdown) {
    final lines = markdown.split('\n');
    if (lines.isEmpty || lines.first.trim() != '---') return markdown;

    int endIndex = -1;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim() == '---') {
        endIndex = i;
        break;
      }
    }

    if (endIndex == -1) return markdown;
    return lines.sublist(endIndex + 1).join('\n').trimLeft();
  }

  /// Extracts headings from markdown for building a Table of Contents.
  List<DocumentHeading> _extractHeadings(String markdown) {
    final headings = <DocumentHeading>[];
    final headingRegex = RegExp(r'^(#{1,6})\s+(.+)$', multiLine: true);

    for (final match in headingRegex.allMatches(markdown)) {
      headings.add(
        DocumentHeading(
          level: match.group(1)!.length,
          title: match.group(2)!.trim(),
        ),
      );
    }

    return headings;
  }
}
