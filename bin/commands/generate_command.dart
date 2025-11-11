import 'dart:io';
import 'structure_command.dart';
import 'move_command.dart';
import 'declare_command.dart';

class GenerateCommandInput {
  final String sourcePath;
  final String assetsRoot;
  final String pubspecPath;
  final String? structureOutputPath;
  final int? maxDepth;

  const GenerateCommandInput({
    required this.sourcePath,
    required this.assetsRoot,
    required this.pubspecPath,
    this.structureOutputPath,
    this.maxDepth,
  });
}

/// Runs structure, move, and declare commands in sequence
Future<void> generateCommand(GenerateCommandInput input) async {
  // Step 1: Generate structure
  final structurePath = input.structureOutputPath ?? 'structure.json';

  await structureCommand(
    StructureCommandInput(
      sourcePath: input.sourcePath,
      outputPath: structurePath,
      maxDepth: input.maxDepth,
    ),
  );

  // Step 2: Move files to assets
  await moveCommand(
    MoveCommandInput(
      structurePath: structurePath,
      sourceRoot: input.sourcePath,
      assetsRoot: input.assetsRoot,
    ),
  );

  // Step 3: Declare assets in pubspec
  await declareCommand(
    DeclareCommandInput(
      assetsRoot: input.assetsRoot,
      pubspecPath: input.pubspecPath,
    ),
  );

  // Clean up temporary structure file if not specified
  if (input.structureOutputPath == null) {
    final tempFile = File(structurePath);
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  }
}
