import 'dart:convert';
import 'dart:io';
import '../core/directory_scanner.dart';

class StructureCommandInput {
  final String sourcePath;
  final String? outputPath;
  final int? maxDepth;

  const StructureCommandInput({
    required this.sourcePath,
    this.outputPath,
    this.maxDepth,
  });
}

class StructureCommandOutput {
  final String? outputPath;
  final Map<String, dynamic> structure;

  const StructureCommandOutput({required this.structure, this.outputPath});
}

/// Generates a JSON file with the folder structure of all files.
Future<StructureCommandOutput> structureCommand(StructureCommandInput input) async {
  final sourceDir = Directory(input.sourcePath);
  if (!await sourceDir.exists()) {
    throw Exception('Source directory does not exist: ${input.sourcePath}');
  }

  final structure = await _generateStructure(sourceDir, input.maxDepth);

  if (input.outputPath case final outputPath?) {
    final jsonOutput = JsonEncoder.withIndent('  ').convert(structure);
    final outputFile = File(outputPath);
    await outputFile.writeAsString(jsonOutput);
  }

  return StructureCommandOutput(
    structure: structure,
    outputPath: input.outputPath,
  );
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
