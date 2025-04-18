import 'dart:io';

import 'package:supabase_codegen/src/generator/generator.dart';

// coverage:ignore-file

/// Generate schema files
Future<void> generateSchemaFiles(
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  final enumsDir = Directory('$root/enums');
  await enumsDir.create(recursive: true);

  // Generate enums file
  await generateEnums(enumsDir);

  logger.d('[GenerateTypes] Successfully generated schema files');
}
