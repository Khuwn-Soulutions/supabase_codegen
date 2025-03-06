import 'dart:io';
import 'package:args/args.dart';
import 'package:logger/web.dart';
import 'src/src.dart';

void main(List<String> args) async {
  try {
    /// Parse options from command line
    const envOption = 'env';
    const outputOption = 'output';
    const tagOption = 'tag';
    const debugOption = 'debug';
    final parser = ArgParser()
      ..addOption(envOption, abbr: envOption[0], defaultsTo: '.env')
      ..addOption(
        outputOption,
        abbr: outputOption[0],
        defaultsTo: 'supabase/types',
      )
      ..addOption(tagOption, abbr: tagOption[0], defaultsTo: '')
      ..addFlag(debugOption, abbr: debugOption[0]);
    final results = parser.parse(args);

    // Pull out optioins
    final envFilePath = results.option(envOption)!;
    final outputFolder = results.option(outputOption)!;
    final tag = results.option(tagOption)!;
    final debug = results.flag(debugOption);

    /// Set the log level if debug is true
    final level = debug ? Level.all : Level.info;
    logger = Logger(
      level: level,
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        excludeBox: {Level.debug: true, Level.info: true},
        printEmojis: false,
      ),
    );

    /// Generate the types using the command line options
    await generateSupabaseTypes(
      envFilePath: envFilePath,
      outputFolder: outputFolder,
      tag: tag,
    );

    /// Format generated files
    await Process.run('dart', ['format', outputFolder]);
    exit(0);
  } on Exception catch (e) {
    // Use print to debug code
    // ignore: avoid_print
    logger.d('Error: $e');
    exit(1);
  }
}
