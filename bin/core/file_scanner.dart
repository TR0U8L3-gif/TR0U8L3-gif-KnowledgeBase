
import 'dart:io';
import 'package:path/path.dart' as path;
import 'frontmatter.dart';

/// Handles file information extraction and metadata.
Future<Map<String, dynamic>?> scanFile(
  File file, {
  required String relativeTo,
}) async {
  final stat = await file.stat();
  final extension = path.extension(file.path).toLowerCase();
  final frontmatter = await readFileFrontmatter(file);

  final fallbackName = path.basename(file.path);
  final name = frontmatter.name?.trim().isNotEmpty == true
      ? frontmatter.name!.trim()
      : fallbackName;

  final relativePath = path.relative(file.path, from: relativeTo);

  final lastModified = frontmatter.lastModified ?? stat.modified;
  final created = frontmatter.created ?? stat.changed;

  if(frontmatter.display == false) {
    return null;
  }

  return {
    'type': 'file',
    'name': name,
    'path': relativePath,
    'description': frontmatter.description,
    'tags': frontmatter.tags,
    'image': frontmatter.image,
    'last_modified': lastModified.toIso8601String(),
    'created': created.toIso8601String(),
    'extension': extension.replaceFirst('.', ''),
  };
}
