import 'dart:io';
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'commands/structure_command.dart';
import 'commands/move_command.dart';
import 'commands/declare_command.dart';

const String defaultAssetsDir = 'doc_assets';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false)
    ..addCommand('structure', _buildStructureParser())
    ..addCommand('move', _buildMoveParser())
    ..addCommand('declare', _buildDeclareParser());

  try {
    final results = parser.parse(arguments);

    if (results['help'] == true) {
      _printUsage(parser);
      exit(0);
    }

    final command = results.command?.name ?? 'structure';
    final commandArgs = results.command ?? results;

    switch (command) {
      case 'move':
        await _runMove(commandArgs);
        break;
      case 'declare':
        await _runDeclare(commandArgs);
        break;
      case 'structure':
      default:
        await _runStructure(commandArgs);
        break;
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    stderr.writeln('');
    _printUsage(parser);
    exit(1);
  }
}

ArgParser _buildStructureParser() {
  return ArgParser()
    ..addOption(
      'source',
      abbr: 's',
      help: 'Source directory to scan',
      mandatory: true,
    )
    ..addOption('output', abbr: 'o', help: 'Output JSON file path')
    ..addOption(
      'max-depth',
      abbr: 'd',
      help: 'Maximum directory depth to scan',
      defaultsTo: '16',
    );
}

ArgParser _buildMoveParser() {
  return ArgParser()
    ..addOption(
      'structure',
      abbr: 'i',
      help: 'Input structure JSON file',
      mandatory: true,
    )
    ..addOption(
      'source',
      abbr: 's',
      help:
          'Root directory that contains the files referenced by the structure',
      mandatory: true,
    )
    ..addOption(
      'assets',
      abbr: 'a',
      help: 'Assets output directory',
      defaultsTo: defaultAssetsDir,
    );
}

ArgParser _buildDeclareParser() {
  return ArgParser()
    ..addOption(
      'assets',
      abbr: 'a',
      help: 'Assets directory to scan',
      defaultsTo: defaultAssetsDir,
    )
    ..addOption(
      'pubspec',
      abbr: 'p',
      help: 'Path to pubspec.yaml',
      defaultsTo: 'pubspec.yaml',
    );
}

Future<void> _runStructure(ArgResults args) async {
  final logger = Logger.standard();

  final sourcePath = args['source'] as String?;
  if (sourcePath == null || sourcePath.isEmpty) {
    throw ArgumentError('Missing required --source');
  }

  final outputPath = args['output'] as String?;
  final maxDepth = (args['max-depth'] as String?) != null
      ? int.tryParse(args['max-depth'] as String)
      : null;

  logger.stdout('Scanning directory: $sourcePath');
  final progress = logger.progress('Generating structure');

  await structureCommand(
    StructureCommandInput(
      sourcePath: sourcePath,
      outputPath: outputPath,
      maxDepth: maxDepth,
    ),
  );

  progress.finish(showTiming: true);
  logger.stdout('Structure saved to: ${outputPath ?? '<stdout only>'}');
}

Future<void> _runMove(ArgResults args) async {
  final logger = Logger.standard();

  final structurePath = args['structure'] as String?;
  final sourceRoot = args['source'] as String?;
  final assetsRoot = args['assets'] as String?;

  if (structurePath == null || sourceRoot == null || assetsRoot == null) {
    throw ArgumentError('Missing required --structure, --source, or --assets');
  }

  logger.stdout('Copying assets from $sourceRoot using $structurePath');
  final progress = logger.progress('Copying to $assetsRoot');

  await moveCommand(
    MoveCommandInput(
      structurePath: structurePath,
      sourceRoot: sourceRoot,
      assetsRoot: assetsRoot,
    ),
  );

  progress.finish(showTiming: true);
  logger.stdout('Assets copied to: $assetsRoot');
}

Future<void> _runDeclare(ArgResults args) async {
  final logger = Logger.standard();

  final assetsRoot = args['assets'] as String?;
  final pubspecPath = args['pubspec'] as String?;

  if (assetsRoot == null || pubspecPath == null) {
    throw ArgumentError('Missing required --assets or --pubspec');
  }

  logger.stdout('Declaring assets from $assetsRoot in $pubspecPath');
  final progress = logger.progress('Updating pubspec.yaml');

  await declareCommand(
    DeclareCommandInput(
      assetsRoot: assetsRoot,
      pubspecPath: pubspecPath,
    ),
  );

  progress.finish(showTiming: true);
  logger.stdout('Assets declared in: $pubspecPath');
}

void _printUsage(ArgParser parser) {
  Logger.standard()
    ..stdout('Usage: dart run bin/run.dart <command> [options]')
    ..stdout('Commands:')
    ..stdout('  structure  Generate structure JSON (default if no command)')
    ..stdout('  move       Copy files to assets from a structure JSON')
    ..stdout('  declare    Add assets to pubspec.yaml')
    ..stdout('')
    ..stdout('Global options:')
    ..stdout(parser.usage)
    ..stdout('')
    ..stdout('Structure options:')
    ..stdout(_buildStructureParser().usage)
    ..stdout('')
    ..stdout('Move options:')
    ..stdout(_buildMoveParser().usage)
    ..stdout('')
    ..stdout('Declare options:')
    ..stdout(_buildDeclareParser().usage);
}
