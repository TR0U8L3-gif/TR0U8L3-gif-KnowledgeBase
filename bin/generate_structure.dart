import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'utils/directory_scanner.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'source',
      abbr: 's',
      help: 'Source directory to scan',
      mandatory: true,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output JSON file path',
      defaultsTo: 'structure.json',
    )
    ..addOption(
      'max-depth',
      abbr: 'd',
      help: 'Maximum directory depth to scan',
      defaultsTo: '16',
    )
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printUsage(parser);
      exit(0);
    }

    final logger = Logger.standard();
    final sourcePath = results['source'] as String;
    final outputPath = results['output'] as String;
    final maxDepth = int.tryParse(results['max-depth'] as String);

    final sourceDir = Directory(sourcePath);
    if (!await sourceDir.exists()) {
      logger.stderr('Error: Source directory does not exist: $sourcePath');
      exit(1);
    }

    logger.stdout('Scanning directory: $sourcePath');
    final progress = logger.progress('Generating structure');

    final structure = await _generateStructure(sourceDir, maxDepth);

    final jsonOutput = JsonEncoder.withIndent('  ').convert(structure);
    final outputFile = File(outputPath);
    await outputFile.writeAsString(jsonOutput);

    progress.finish(showTiming: true);
    logger.stdout('Structure saved to: $outputPath');
  } catch (e) {
    stderr.writeln('Error: $e');
    stderr.writeln('');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  Logger.standard()
    ..stdout('Usage: dart run bin/generate_structure.dart --source <path>')
    ..stdout('')
    ..stdout('Generate a JSON file with the folder structure of all files.')
    ..stdout('')
    ..stdout(parser.usage);
}

Future<Map<String, dynamic>> _generateStructure(Directory root, int? maxDepth) async {
  final rootCatalog = await scanDirectory(root, root.path, 0, maxDepth ?? maxDepthDefault);
  return {
    'root': root.path,
    'generated': DateTime.now().toIso8601String(),
    'catalog': rootCatalog,
  };
}
