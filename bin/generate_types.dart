import 'dart:io';
import 'package:args/args.dart';
import 'src/generate_supabase_types.dart';

void main(List<String> args) async {
  try {
    /// Parse options from command line
    const envOption = 'env';
    const outputOption = 'output';
    const tagOption = 'tag';
    final parser = ArgParser()
      ..addOption(envOption, abbr: envOption[0], defaultsTo: '.env')
      ..addOption(
        outputOption,
        abbr: outputOption[0],
        defaultsTo: 'supabase/types',
      )
      ..addOption(tagOption, abbr: tagOption[0], defaultsTo: '');
    final results = parser.parse(args);

    // Pull out optioins
    final envFilePath = results.option(envOption)!;
    final outputFolder = results.option(outputOption)!;
    final tag = results.option(tagOption)!;

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
    print('Error: $e');
    exit(1);
  }
}
