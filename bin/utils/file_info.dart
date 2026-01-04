import 'dart:io';
import 'package:yaml/yaml.dart';

/// Parsed frontmatter values.
class Frontmatter {
  const Frontmatter({
    this.name,
    this.description,
    this.tags,
    this.image,
    this.created,
    this.lastModified,
  });

  final String? name;
  final String? description;
  final List<String>? tags;
  final String? image;
  final DateTime? created;
  final DateTime? lastModified;
}

/// Attempts to read YAML frontmatter from the file content.
Future<Frontmatter> readFrontmatter(File file) async {
  try {
    final content = await file.readAsString();
    final raw = _extractFrontmatter(content);
    if (raw == null) return const Frontmatter();

    return Frontmatter(
      name: _asString(raw['name']),
      description: _asString(raw['description']),
      tags: _asStringList(raw['tags']),
      image: _asString(raw['image']),
      created: _parseDate(raw['created']),
      lastModified: _parseDate(raw['last_modified'] ?? raw['updated']),
    );
  } catch (_) {
    return const Frontmatter();
  }
}

Map<String, dynamic>? _extractFrontmatter(String content) {
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

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<String>? _asStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    final items = value
        .map((e) => e?.toString().trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    return items.isEmpty ? null : items;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : [text];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  final iso = DateTime.tryParse(text);
  if (iso != null) return iso;

  final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(text);
  if (match != null) {
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    return DateTime.utc(year, month, day);
  }

  return null;
}
