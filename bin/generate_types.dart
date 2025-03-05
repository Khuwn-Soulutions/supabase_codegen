import 'dart:io';
import 'package:args/args.dart';
import 'src/generate_supabase_types.dart';

void main(List<String> args) async {
  try {
    /// Parse options from command line
    const envOption = 'env';
    const outputOption = 'output';
    final parser = ArgParser()
      ..addOption(envOption, abbr: envOption[0], defaultsTo: '.env')
      ..addOption(
        outputOption,
        abbr: outputOption[0],
        defaultsTo: 'supabase/types',
      );
    final results = parser.parse(args);
    final outputFolder = results.option(outputOption)!;

    /// Generate the types using hte command line options
    await generateSupabaseTypes(
      envFilePath: results.option(envOption)!,
      outputFolder: outputFolder,
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
