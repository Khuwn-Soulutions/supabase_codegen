import 'dart:io';
import 'package:args/args.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

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

    /// Generate the types using hte command line options
    await generateSupabaseTypes(
      envFilePath: results.option(envOption)!,
      outputFolder: results.option(outputOption)!,
    );
    exit(0);
  } on Exception catch (e) {
    // Use print to debug code
    // ignore: avoid_print
    print('Error: $e');
    exit(1);
  }
}
