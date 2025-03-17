import 'dart:io';
import 'package:args/args.dart';
import 'package:logger/web.dart';
import 'package:yaml/yaml.dart';
import 'src/src.dart';

/// Main function
void main(List<String> args) async {
  await runGenerateTypes(args);
}

/// Default option values
const defaultValues = {
  'env': '.env',
  'output': 'supabase/types',
  'tag': '',
  'debug': false,
  'skipFooter': false,
};

/// Get the code genreator configuration from the root pubspec.yaml file
Map<String, dynamic> getPubspecConfig([File? file]) {
  final pubSpecFile = file ?? File('pubspec.yaml');
  final pubspecContents = pubSpecFile.readAsStringSync();
  final pubspec = loadYaml(pubspecContents) as YamlMap;
  final codegenConfig = pubspec['supabase_codegen'] as YamlMap? ?? {};
  return Map<String, dynamic>.from(codegenConfig);
}

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
        help: 'Path to .env file',
      )
      // Output Folder
      ..addOption(
        outputOption,
        abbr: outputOption[0],
        help: 'Path to output folder',
      )
      // Tag
      ..addOption(
        tagOption,
        abbr: tagOption[0],
        help: 'Tag to add to generated files',
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
    final codegenConfig = getPubspecConfig(pubspecFile);

    /// Helper function to get option value
    String optionValueFor(String option) => results.wasParsed(option)
        ? results.option(option)!
        : (codegenConfig[option] as String?) ??
            defaultValues[option]!.toString();

    /// Helper function to get flag value
    bool flagValueFor(String option) => results.wasParsed(option)
        ? results.flag(option)
        : (codegenConfig[option] as bool?) ?? defaultValues[option]! as bool;

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
