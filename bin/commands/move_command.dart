import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class MoveCommandInput {
  final String structurePath;
  final String sourceRoot;
  final String assetsRoot;

  const MoveCommandInput({
    required this.structurePath,
    required this.sourceRoot,
    required this.assetsRoot,
  });
}

/// Copies files and directories described by the structure JSON into assets,
/// and writes index.json with the same content.
Future<void> moveCommand(MoveCommandInput input) async {
  final structureFile = File(input.structurePath);
  if (!await structureFile.exists()) {
    throw Exception('Structure file does not exist: ${input.structurePath}');
  }

  final decoded = jsonDecode(await structureFile.readAsString());
  if (decoded is! Map<String, dynamic> || decoded['directory'] == null) {
    throw Exception('Invalid structure file: missing "directory" root object');
  }

  final rootNode = decoded['directory'] as Map<String, dynamic>;

  final assetsRootDir = Directory(input.assetsRoot);
  await assetsRootDir.create(recursive: true);

  await _copyDirectoryTree(
    node: rootNode,
    sourceRoot: input.sourceRoot,
    assetsRoot: input.assetsRoot,
  );

  final indexFile = File(p.join(input.assetsRoot, 'index.json'));
  final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
  await indexFile.writeAsString(pretty);
}

Future<void> _copyDirectoryTree({
  required Map<String, dynamic> node,
  required String sourceRoot,
  required String assetsRoot,
}) async {
  final pathValue = node['path'] as String? ?? '.';
  final normalizedPath = pathValue == '.' ? '' : pathValue;

  final destDir = Directory(p.join(assetsRoot, normalizedPath));
  await destDir.create(recursive: true);

  final items = node['items'];
  if (items is! List) return;

  for (final raw in items) {
    if (raw is! Map<String, dynamic>) continue;
    final type = raw['type'] as String?;
    if (type == 'directory') {
      await _copyDirectoryTree(
        node: raw,
        sourceRoot: sourceRoot,
        assetsRoot: assetsRoot,
      );
    } else if (type == 'file') {
      final relativePath = raw['path'] as String?;
      if (relativePath == null) continue;

      final sourcePath = p.join(sourceRoot, relativePath);
      final destPath = p.join(assetsRoot, relativePath);
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        stderr.writeln('Warning: source file missing, skipping: $sourcePath');
        continue;
      }

      await File(destPath).parent.create(recursive: true);
      await sourceFile.copy(destPath);
    }
  }
}
