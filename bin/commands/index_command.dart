import 'dart:convert';
import 'dart:io';
import '../utils/directory_scanner.dart';

/// Generates a JSON file with the folder structure of all files.
Future<void> indexCommand({
  required String sourcePath,
  required String outputPath,
  int? maxDepth,
}) async {
  final sourceDir = Directory(sourcePath);
  if (!await sourceDir.exists()) {
    throw Exception('Source directory does not exist: $sourcePath');
  }

  final structure = await _generateStructure(sourceDir, maxDepth);

  final jsonOutput = JsonEncoder.withIndent('  ').convert(structure);
  final outputFile = File(outputPath);
  await outputFile.writeAsString(jsonOutput);
}

Future<Map<String, dynamic>> _generateStructure(
  Directory root,
  int? maxDepth,
) async {
  final rootCatalog = await scanDirectory(
    root,
    root.path,
    0,
    maxDepth ?? maxDepthDefault,
  );
  return {
    'generated': DateTime.now().toIso8601String(),
    'directory': rootCatalog,
  };
}
