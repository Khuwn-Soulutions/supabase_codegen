import 'dart:io';

import 'package:args/args.dart';
import 'package:change_case/change_case.dart';
import 'package:logger/logger.dart';
import 'package:supabase_codegen/src/generator/generator.dart';

/// Generate the supabase types using the [args] provided
Future<String?> runGenerateTypes(
  List<String> args, {
  SupabaseCodeGenerator generator = const SupabaseCodeGenerator(),
  File? pubspecFile,
  bool forFlutter = false,
}) async {
  /// Are we running in test mode
  final isRunningInTest = Platform.script.path.contains('test.dart') ||
      Platform.environment['FLUTTER_TEST'] == 'true';

  try {
    /// Get the parser for the argument.
    /// If an option is not set the default value will be extracted from
    /// the pubspec file with a predefined fallback if not set in pubspec
    final parser = ArgParser()
      // Help
      ..addFlag(
        CmdOption.help,
        abbr: CmdOption.help[0],
        help: 'Show help',
      )
      // Env
      ..addOption(
        CmdOption.env,
        abbr: CmdOption.env[0],
        defaultsTo: defaultValues[CmdOption.env] as String,
        help: 'Path to .env file',
      )
      // Output Folder
      ..addOption(
        CmdOption.output,
        abbr: CmdOption.output[0],
        defaultsTo: defaultValues[CmdOption.output] as String,
        help: 'Path to output folder',
      )
      // Tag
      ..addOption(
        CmdOption.tag,
        abbr: CmdOption.tag[0],
        defaultsTo: defaultValues[CmdOption.tag] as String,
        help: 'Tag to add to generated files',
      )
      // Config yaml path
      ..addOption(
        CmdOption.configYaml,
        defaultsTo: defaultValues[CmdOption.configYaml] as String,
        abbr: CmdOption.configYaml[0],
        help: 'Path to config yaml file. \n'
            'If not specified, reads from .supabase_codegen.yaml or keys under '
            'supabase_codegen in pubspec.yaml',
      )
      // Debug
      ..addFlag(
        CmdOption.debug,
        abbr: CmdOption.debug[0],
        help: 'Enable debug logging',
      )
      // Skip footer
      ..addFlag(
        CmdOption.skipFooter,
        abbr: CmdOption.skipFooter[0],
        help: 'Skip footer generation',
      );
    final results = parser.parse(args);

    // Check for help and print usage
    if (results.wasParsed(CmdOption.help)) {
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
    final configFilePath = results.option(CmdOption.configYaml)!;
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
    final envFilePath = optionValueFor(CmdOption.env);
    final outputFolder = optionValueFor(CmdOption.output);
    final tag = optionValueFor(CmdOption.tag);
    final debug = flagValueFor(CmdOption.debug);
    final skipFooter = flagValueFor(CmdOption.skipFooter);

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
      forFlutter: forFlutter,
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
