import 'dart:io';
import 'package:path/path.dart' as path;
import 'file_scanner.dart';
import 'file_analyzer.dart';

const maxDepthDefault = 16;

/// Handles recursive directory scanning and structure generation.
Future<Map<String, dynamic>> scanDirectory(
  Directory dir,
  String rootPath, [
  int depth = 0,
  int maxDepth = maxDepthDefault,
]) async {
  final items = <Map<String, dynamic>>[];
  final frontmatter = await _readDirectoryFrontmatter(dir);

  final fallbackName = path.basename(dir.path);
  final relativePath = path.relative(dir.path, from: rootPath);

  Map<String, dynamic> _directoryResult() => {
    'type': 'directory',
    'name': frontmatter.name ?? fallbackName,
    'path': relativePath,
    'description': frontmatter.description,
    'display': frontmatter.display,
    'icon': frontmatter.icon,
    'items': items,
    'order': frontmatter.order,
  };

  if (depth > maxDepth) {
    stderr.writeln('Warning: Maximum directory depth exceeded at ${dir.path}');
    return _directoryResult();
  }

  try {
    final entities = await dir.list().toList();

    // Sort entities with optional explicit order, then remaining directories/files alphabetically
    entities
      ..sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)))
      ..setAll(0, _applyOrder(entities, frontmatter.order));

    for (final entity in entities) {
      final name = path.basename(entity.path);

      // Skip hidden files and common build directories
      if (name.startsWith('.') ||
          name == 'build' ||
          name == '.dart_tool' ||
          name == '_directory.md' ||
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

  return _directoryResult();
}

List<FileSystemEntity> _applyOrder(
  List<FileSystemEntity> entities,
  List<String>? order,
) {
  if (order == null || order.isEmpty) {
    return _fallbackSort(entities);
  }

  final remaining = <String, FileSystemEntity>{
    for (final entity in entities) path.basename(entity.path): entity,
  };

  final ordered = <FileSystemEntity>[];

  for (final name in order) {
    final entity = remaining.remove(name);
    if (entity != null) {
      ordered.add(entity);
    }
  }

  ordered.addAll(_fallbackSort(remaining.values.toList()));
  return ordered;
}

List<FileSystemEntity> _fallbackSort(List<FileSystemEntity> entities) {
  final directories = <FileSystemEntity>[];
  final files = <FileSystemEntity>[];

  for (final entity in entities) {
    if (entity is Directory) {
      directories.add(entity);
    } else {
      files.add(entity);
    }
  }

  directories.sort(
    (a, b) => path.basename(a.path).compareTo(path.basename(b.path)),
  );
  files.sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)));

  return [...directories, ...files];
}

Future<DirectoryFrontmatter> _readDirectoryFrontmatter(Directory dir) async {
  final fmFile = File(path.join(dir.path, '_directory.md'));
  if (await fmFile.exists()) {
    return readDirectoryFrontmatter(fmFile);
  }
  return const DirectoryFrontmatter();
}
