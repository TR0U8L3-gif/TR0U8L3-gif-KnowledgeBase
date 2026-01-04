import 'dart:io';
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'commands/index_command.dart';

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

    logger.stdout('Scanning directory: $sourcePath');
    final progress = logger.progress('Generating structure');

    await indexCommand(
      sourcePath: sourcePath,
      outputPath: outputPath,
      maxDepth: maxDepth,
    );

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
    ..stdout('Usage: dart run bin/run.dart --source <path>')
    ..stdout('')
    ..stdout('Generate a JSON file with the folder structure of all files.')
    ..stdout('')
    ..stdout(parser.usage);
}
