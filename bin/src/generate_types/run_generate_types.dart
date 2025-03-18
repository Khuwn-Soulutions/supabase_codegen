import 'dart:io';

import 'package:args/args.dart';
import 'package:change_case/change_case.dart';
import 'package:logger/logger.dart';
import '../src.dart';

///

/// Generate the supabase types using the [args] provided
Future<String?> runGenerateTypes(
  List<String> args, {
  SupabaseCodeGenerator generator = const SupabaseCodeGenerator(),
  File? pubspecFile,
}) async {
  /// Are we running in test mode
  final isRunningInTest = Platform.script.path.contains('test.dart');

  try {
    /// Parse options from command line
    const envOption = 'env';
    const outputOption = 'output';
    const tagOption = 'tag';
    const debugOption = 'debug';
    const skipFooterOption = 'skipFooter';
    const helpOption = 'help';
    const configYamlOption = 'config-yaml';

    /// Get the parser for the argument.
    /// If an option is not set the default value will be extracted from
    /// the pubspec file with a predefined fallback if not set in pubspec
    final parser = ArgParser()
      // Help
      ..addFlag(
        helpOption,
        abbr: helpOption[0],
        help: 'Show help',
      )
      // Env
      ..addOption(
        envOption,
        abbr: envOption[0],
        defaultsTo: defaultValues[envOption] as String,
        help: 'Path to .env file',
      )
      // Output Folder
      ..addOption(
        outputOption,
        abbr: outputOption[0],
        defaultsTo: defaultValues[outputOption] as String,
        help: 'Path to output folder',
      )
      // Tag
      ..addOption(
        tagOption,
        abbr: tagOption[0],
        defaultsTo: defaultValues[tagOption] as String,
        help: 'Tag to add to generated files',
      )
      // Config yaml path
      ..addOption(
        configYamlOption,
        defaultsTo: defaultValues[configYamlOption] as String,
        abbr: configYamlOption[0],
        help: 'Path to config yaml file. \n'
            'If not specified, reads from keys under '
            'supabase_codegen in pubspec.yaml',
      )
      // Debug
      ..addFlag(
        debugOption,
        abbr: debugOption[0],
        help: 'Enable debug logging',
      )
      // Skip footer
      ..addFlag(
        skipFooterOption,
        abbr: skipFooterOption[0],
        help: 'Skip footer generation',
      );
    final results = parser.parse(args);

    // Check for help and print usage
    if (results.wasParsed(helpOption)) {
      // Return value instead of printing in test
      if (isRunningInTest) return parser.usage;

      // coverage:ignore-start
      // Use print to display usage
      // ignore: avoid_print
      print(parser.usage);
      exit(0);
      // coverage:ignore-end
    }

    /// Get config values
    final configFilePath = results.option(configYamlOption)!;
    final codegenConfig = getCodegenConfig(
      configFile: File(configFilePath),
      pubspecFile: pubspecFile,
    );

    /// Helper function to get option value
    String optionValueFor(String option) => results.wasParsed(option)
        ? results.option(option)!
        : (codegenConfig[option.toCamelCase()] as String?) ??
            parser.defaultFor(option)! as String;

    /// Helper function to get flag value
    bool flagValueFor(String option) => results.wasParsed(option)
        ? results.flag(option)
        : (codegenConfig[option.toCamelCase()] as bool?) ??
            parser.defaultFor(option)! as bool;

    // Pull out options
    final envFilePath = optionValueFor(envOption);
    final outputFolder = optionValueFor(outputOption);
    final tag = optionValueFor(tagOption);
    final debug = flagValueFor(debugOption);
    final skipFooter = flagValueFor(skipFooterOption);

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
    await generator.generateSupabaseTypes(
      envFilePath: envFilePath,
      outputFolder: outputFolder,
      fileTag: tag,
      skipFooter: skipFooter,
    );

    // coverage:ignore-start
    if (isRunningInTest) return null;

    /// Format generated files
    await Process.run('dart', ['format', outputFolder]);

    exit(0);
    // coverage:ignore-end
  } on Exception catch (e) {
    // In test rethrow error to confirm code block executed
    if (isRunningInTest) rethrow;

    // coverage:ignore-start
    // Use print to debug code
    // ignore: avoid_print
    print('Error: $e');
    exit(1);
    // coverage:ignore-end
  }
}
