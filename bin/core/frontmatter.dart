import 'dart:io';
import 'package:yaml/yaml.dart';

import '../utils/convert.dart';

/// Parsed frontmatter values.
class FileFrontmatter {
  const FileFrontmatter({
    this.name,
    this.description,
    this.display,
    this.tags,
    this.image,
    this.created,
    this.lastModified,
  });

  final String? name;
  final String? description;
  final bool? display;
  final List<String>? tags;
  final String? image;
  final DateTime? created;
  final DateTime? lastModified;
}

/// Parsed frontmatter values.
class DirectoryFrontmatter {
  const DirectoryFrontmatter({
    this.name,
    this.description,
    this.icon,
    this.order,
  });

  final String? name;
  final String? description;
  final String? icon;
  final List<String>? order;
}

/// Attempts to return file frontmatter data from the file content.
Future<FileFrontmatter> readFileFrontmatter(File file) async {
  final data = await readFrontmatter(file);

  if (data == null) return const FileFrontmatter();

  return FileFrontmatter(
    name: Convert.asString(data['name']),
    description: Convert.asString(data['description']),
    display: Convert.asBool(data['display']),
    tags: Convert.asStringList(data['tags']),
    image: Convert.asString(data['image']),
    created: Convert.parseDate(data['created']),
    lastModified: Convert.parseDate(data['last_modified'] ?? data['updated']),
  );
}

/// Attempts to return directory frontmatter data from the file content.
Future<DirectoryFrontmatter> readDirectoryFrontmatter(File file) async {
  final data = await readFrontmatter(file);

  if (data == null) return const DirectoryFrontmatter();

  return DirectoryFrontmatter(
    name: Convert.asString(data['name']),
    description: Convert.asString(data['description']),
    icon: Convert.asString(data['icon']),
    order: Convert.asStringList(data['order']),
  );
}

/// Attempts to read YAML frontmatter from the file content.
Future<Map<String, dynamic>?> readFrontmatter(File file) async {
  try {
    final content = await file.readAsString();
    final raw = extractFrontmatter(content);
    return raw;
  } catch (_) {
    return null;
  }
}

/// Extracts frontmatter from the given content string.
Map<String, dynamic>? extractFrontmatter(String content) {
  final lines = content.split('\n');
  if (lines.isEmpty || lines.first.trim() != '---') return null;

  final endIndex = lines.indexWhere((line) => line.trim() == '---', 1);
  if (endIndex <= 0) return null;

  final yamlSection = lines.sublist(1, endIndex).join('\n');
  final parsed = loadYaml(yamlSection);
  if (parsed is YamlMap) {
    return _yamlToMap(parsed);
  }
  return null;
}

Map<String, dynamic> _yamlToMap(YamlMap map) {
  final result = <String, dynamic>{};
  for (final entry in map.entries) {
    final key = entry.key is YamlScalar ? entry.key.value : entry.key;
    result['$key'] = _yamlNodeToDart(entry.value);
  }
  return result;
}

dynamic _yamlNodeToDart(dynamic node) {
  if (node is YamlMap) {
    return _yamlToMap(node);
  }
  if (node is YamlList) {
    return node.map(_yamlNodeToDart).toList();
  }
  if (node is YamlScalar) {
    return node.value;
  }
  return node;
}
