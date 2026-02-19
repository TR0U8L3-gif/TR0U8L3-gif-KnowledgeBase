import '../../domain/entities/knowledge_base_item.dart';

/// Converts JSON data from index.json into domain entities.
class KnowledgeBaseItemModel {
  /// Parses a JSON map into a [KnowledgeBaseItem] (either directory or file).
  static KnowledgeBaseItem fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    if (type == 'directory') {
      return _parseDirectory(json);
    } else {
      return _parseFile(json);
    }
  }

  static DirectoryItem _parseDirectory(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((e) => fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final order = (json['order'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();

    return DirectoryItem(
      name: json['name'] as String,
      path: json['path'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      items: items,
      order: order,
    );
  }

  static FileItem _parseFile(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'] as String,
      path: json['path'] as String,
      description: json['description'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      image: json['image'] as String?,
      lastModified: json['last_modified'] != null
          ? DateTime.tryParse(json['last_modified'] as String)
          : null,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
      extension: (json['extension'] as String?) ?? '',
    );
  }
}
