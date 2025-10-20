import 'dart:io';

import 'package:supabase_codegen/src/generator/generator.dart';

// coverage:ignore-file

/// Generate schema files
Future<void> generateSchemaFiles([
  Directory? enumsDir,
]) async {
  enumsDir ??= enumsDirectory;

  // Generate enums file
  await generateEnums(enumsDir);

  logger.debug('[GenerateTypes] Successfully generated schema files');
}
