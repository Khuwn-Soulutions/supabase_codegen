import 'dart:io';
import 'package:args/args.dart';
import 'package:logger/web.dart';
import 'package:yaml/yaml.dart';
import 'src/src.dart';

void main(List<String> args) async {
  try {
    /// Parse options from command line
    const envOption = 'env';
    const outputOption = 'output';
    const tagOption = 'tag';
    const debugOption = 'debug';
    const skipFooterOption = 'skip-footer';

    /// Get default values from pubspec
    final pubSpecFile = File('pubspec.yaml');
    final pubspecContents = pubSpecFile.readAsStringSync();
    final pubspec = loadYaml(pubspecContents) as YamlMap;
    final codegenConfig = pubspec['supabase_codegen'] as YamlMap? ?? {};

    /// Get the parser for the argument.
    /// If an option is not set the default value will be extracted from
    /// the pubspec file with a predefined fallback if not set in pubspec
    final parser = ArgParser()
      // Env
      ..addOption(
        envOption,
        abbr: envOption[0],
        defaultsTo: codegenConfig[envOption] as String? ?? '.env',
      )
      // Output Folder
      ..addOption(
        outputOption,
        abbr: outputOption[0],
        defaultsTo: codegenConfig[outputOption] as String? ?? 'supabase/types',
      )
      // Tag
      ..addOption(
        tagOption,
        abbr: tagOption[0],
        defaultsTo: codegenConfig[tagOption] as String? ?? '',
      )
      // Debug
      ..addFlag(
        debugOption,
        abbr: debugOption[0],
        defaultsTo: codegenConfig[debugOption] as bool? ?? false,
      )
      // Skip footer
      ..addFlag(
        skipFooterOption,
        abbr: skipFooterOption[0],
        defaultsTo: codegenConfig[skipFooterOption] as bool? ?? false,
      );
    final results = parser.parse(args);

    // Pull out options
    final envFilePath = results.option(envOption)!;
    final outputFolder = results.option(outputOption)!;
    final tag = results.option(tagOption)!;
    final debug = results.flag(debugOption);
    final skipFooter = results.flag(skipFooterOption);

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
      fileTag: tag,
      skipFooter: skipFooter,
    );

    /// Format generated files
    await Process.run('dart', ['format', outputFolder]);
    exit(0);
  } on Exception catch (e) {
    // Use print to debug code
    // ignore: avoid_print
    print('Error: $e');
    exit(1);
  }
}
