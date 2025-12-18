import 'dart:io';

import 'package:supabase_codegen/src/generator/generator.dart';
import 'add_codegen_functions.dart';

/// Main function
void main(List<String> args) async {
  try {
    await checkMigration();
    await runGenerateTypes(args, config: GeneratorConfigParams.empty());
  }
  // Catch and log any errors or exceptions
  // ignore: avoid_catches_without_on_clauses
  catch (e, stackTrace) {
    // Log the error message
    logger
      ..err('Error while generating types: $e')
      ..detail('Stack trace:\n$stackTrace');
    exit(1);
  }
}
