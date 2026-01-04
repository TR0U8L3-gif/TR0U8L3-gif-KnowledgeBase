import 'dart:io';
import 'package:path/path.dart' as p;

class DeclareCommandInput {
  final String assetsRoot;
  final String pubspecPath;

  const DeclareCommandInput({
    required this.assetsRoot,
    required this.pubspecPath,
  });
}

/// Scans assets directory and adds all files to pubspec.yaml flutter: assets:
Future<void> declareCommand(DeclareCommandInput input) async {
  final assetsDir = Directory(input.assetsRoot);
  if (!await assetsDir.exists()) {
    throw Exception('Assets directory does not exist: ${input.assetsRoot}');
  }

  final pubspecFile = File(input.pubspecPath);
  if (!await pubspecFile.exists()) {
    throw Exception('pubspec.yaml not found: ${input.pubspecPath}');
  }

  final assetPaths = await _collectAssetPaths(assetsDir, input.assetsRoot);
  await _updatePubspecAssets(pubspecFile, assetPaths);
}

Future<List<String>> _collectAssetPaths(Directory dir, String rootPath) async {
  final paths = <String>[];

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File) {
      final relativePath = p.relative(entity.path, from: rootPath);
      // Use forward slashes for asset paths
      final assetPath = relativePath.replaceAll(r'\', '/');
      paths.add('$rootPath/$assetPath');
    }
  }

  paths.sort();
  return paths;
}

Future<void> _updatePubspecAssets(
  File pubspecFile,
  List<String> assetPaths,
) async {
  final content = await pubspecFile.readAsString();
  final lines = content.split('\n');

  // Find flutter: section
  int? flutterIndex;
  int? assetsIndex;
  int indentSize = 2;

  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trimLeft();
    if (trimmed.startsWith('flutter:')) {
      flutterIndex = i;
      continue;
    }

    if (flutterIndex != null && trimmed.startsWith('assets:')) {
      assetsIndex = i;
      final indent = lines[i].indexOf('assets:');
      indentSize = indent;
      break;
    }
  }

  // Build new assets section
  final assetLines = assetPaths
      .map((path) => '${' ' * (indentSize + 2)}- $path')
      .toList();

  final newLines = <String>[];

  if (flutterIndex == null) {
    // No flutter section, add at end
    newLines.addAll(lines);
    newLines.add('');
    newLines.add('flutter:');
    newLines.add('  assets:');
    newLines.addAll(assetLines);
  } else if (assetsIndex == null) {
    // Flutter section exists but no assets
    newLines.addAll(lines.sublist(0, flutterIndex + 1));
    newLines.add('${' ' * indentSize}assets:');
    newLines.addAll(assetLines);
    newLines.addAll(lines.sublist(flutterIndex + 1));
  } else {
    // Assets section exists, replace it
    // Find where assets section ends
    int assetsEnd = assetsIndex + 1;
    final assetsIndent = lines[assetsIndex].indexOf('assets:');

    for (var i = assetsIndex + 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      final leadingSpaces = line.length - line.trimLeft().length;
      if (leadingSpaces <= assetsIndent) {
        // Found next section
        assetsEnd = i;
        break;
      }
      assetsEnd = i + 1;
    }

    newLines.addAll(lines.sublist(0, assetsIndex + 1));
    newLines.addAll(assetLines);
    newLines.addAll(lines.sublist(assetsEnd));
  }

  await pubspecFile.writeAsString(newLines.join('\n'));
}
