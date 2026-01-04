import 'dart:io';
import 'package:path/path.dart' as path;
import 'file_scanner.dart';

const maxDepthDefault = 16;

/// Handles recursive directory scanning and structure generation.
Future<Map<String, dynamic>> scanDirectory(
  Directory dir,
  String rootPath, [
  int depth = 0,
  int maxDepth = maxDepthDefault,
]) async {
  final items = <Map<String, dynamic>>[];

  if (depth > maxDepth) {
    stderr.writeln('Warning: Maximum directory depth exceeded at ${dir.path}');
    return {
      'type': 'catalog',
      'name': path.basename(dir.path),
      'path': path.relative(dir.path, from: rootPath),
      'items': items,
    };
  }

  try {
    final entities = await dir.list().toList();

    // Sort entities: directories first, then files
    entities.sort((a, b) {
      final aIsDir = a is Directory;
      final bIsDir = b is Directory;
      if (aIsDir && !bIsDir) return -1;
      if (!aIsDir && bIsDir) return 1;
      return path.basename(a.path).compareTo(path.basename(b.path));
    });

    for (final entity in entities) {
      final name = path.basename(entity.path);

      // Skip hidden files and common build directories
      if (name.startsWith('.') ||
          name == 'build' ||
          name == '.dart_tool' ||
          name == 'node_modules') {
        continue;
      }

      if (entity is Directory) {
        final subCatalog = await scanDirectory(
          entity,
          rootPath,
          depth + 1,
          maxDepth,
        );
        items.add(subCatalog);
      } else if (entity is File) {
        final fileInfo = await scanFile(entity, relativeTo: rootPath);
        items.add(fileInfo);
      }
    }
  } catch (e) {
    stderr.writeln('Warning: Could not scan ${dir.path}: $e');
  }

  return {
    'type': 'catalog',
    'name': path.basename(dir.path),
    'path': path.relative(dir.path, from: rootPath),
    'items': items,
  };
}
