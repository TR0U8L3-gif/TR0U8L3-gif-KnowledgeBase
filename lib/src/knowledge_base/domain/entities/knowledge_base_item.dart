/// Sealed class representing an item in the knowledge base tree.
///
/// Can be either a [DirectoryItem] (folder with children)
/// or a [FileItem] (leaf document).
sealed class KnowledgeBaseItem {
  final String name;
  final String path;

  const KnowledgeBaseItem({required this.name, required this.path});
}

/// A directory node in the knowledge base tree.
class DirectoryItem extends KnowledgeBaseItem {
  final String? description;
  final String? icon;
  final List<KnowledgeBaseItem> items;
  final List<String>? order;

  const DirectoryItem({
    required super.name,
    required super.path,
    this.description,
    this.icon,
    required this.items,
    this.order,
  });

  /// Returns items sorted according to the [order] list.
  /// Items not in [order] appear after ordered items.
  List<KnowledgeBaseItem> get sortedItems {
    if (order == null || order!.isEmpty) return items;

    final orderMap = <String, int>{};
    for (int i = 0; i < order!.length; i++) {
      orderMap[order![i]] = i;
    }

    final ordered = List<KnowledgeBaseItem>.from(items);
    ordered.sort((a, b) {
      final aSegment = a.path.split('/').last;
      final bSegment = b.path.split('/').last;
      final aOrder = orderMap[aSegment];
      final bOrder = orderMap[bSegment];

      if (aOrder != null && bOrder != null) return aOrder.compareTo(bOrder);
      if (aOrder != null) return -1;
      if (bOrder != null) return 1;
      return 0;
    });

    return ordered;
  }
}

/// A file (document) node in the knowledge base tree.
class FileItem extends KnowledgeBaseItem {
  final String? description;
  final List<String> tags;
  final String? image;
  final DateTime? lastModified;
  final DateTime? created;
  final String extension;

  const FileItem({
    required super.name,
    required super.path,
    this.description,
    required this.tags,
    this.image,
    this.lastModified,
    this.created,
    required this.extension,
  });
}
