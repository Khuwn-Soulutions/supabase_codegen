import 'dart:io';

import 'package:change_case/change_case.dart';

import 'package:supabase_codegen/src/generator/generator.dart';

/// Generate enums
Future<void> generateEnums(Directory enumsDir) async {
  final enumFile = File('${enumsDir.path}/$enumsFileName.dart');
  // Add header comment and imports
  final buffer = StringBuffer();

  writeHeader(buffer);

  // Fetch enum types from database
  logger.i('[GenerateTypes] Fetching enum types from database...');

  try {
    // Query to get all enum types and their values
    logger.d('[GenerateTypes] Executing RPC call to get_enum_types...');
    final response = await client.rpc<dynamic>('get_enum_types');

    // Modified to handle direct List response
    // ignore: avoid_dynamic_calls
    final enumData = List<Map<String, dynamic>>.from(
      response is List
          ? response
          :
          // Get data from the response if not a List
          // ignore: avoid_dynamic_calls
          response['data'] as List,
    );

    logger
      ..d('[GenerateTypes] Raw enum response data:')
      ..d(enumData);

    final enums = <String, List<String>>{};

    // Process the response data
    logger.d('[GenerateTypes] Processing enum types:');
    for (final row in enumData) {
      final enumName = row['enum_name'] as String;
      final enumValue = (row['enum_value'] as String).replaceAll('/', '_');

      logger.d('  Found enum: $enumName with value: $enumValue');

      if (!enums.containsKey(enumName)) {
        enums[enumName] = [];
        logger.d('  Created new enum list for: $enumName');
      }
      enums[enumName]!.add(enumValue);
    }

    // Generate each enum
    logger.d('[GenerateTypes] Generating enum definitions:');
    enums.forEach((enumName, values) async {
      // Format enum name to PascalCase and remove Enum suffix
      final formattedEnumName = enumName
          .split('_')
          .map((word) => word.toTitleCase())
          .join()
          .replaceAll(RegExp(r'Enum$'), '');

      logger.d('  Processing: $enumName -> $formattedEnumName');
      formattedEnums[enumName] = formattedEnumName;

      final enumBuffer = StringBuffer();
      final fileName = formattedEnumName.toSnakeCase();
      final enumFile = File('${enumsDir.path}/$fileName.dart');

      /// Add header comment and imports
      writeHeader(enumBuffer);

      /// Document and start enum declaration
      enumBuffer
        ..writeln('/// ${formattedEnumName.toCapitalCase()} enum')
        ..writeln('enum $formattedEnumName {');

      /// Write enum fields
      for (final value in values) {
        enumBuffer
          ..writeln('  /// $value')
          ..writeln('  $value,');
      }

      /// Close enum declaration
      enumBuffer
        ..writeln('}')
        ..writeln();

      /// Write footer
      writeFooter(enumBuffer);

      /// Write file to disk
      enumFile.writeAsStringSync(enumBuffer.toString());

      logger.i('[GenerateTypes] Generated enum file: $fileName');

      /// Write the filename to the main buffer file
      buffer.writeln("export '$fileName.dart';");
    });

    /// Write footer
    writeFooter(buffer);

    /// Write file to disk
    await enumFile.writeAsString(buffer.toString());
    logger.i('[GenerateTypes] Generated enums file successfully');
  } catch (e, stackTrace) {
    logger.e(
      '[GenerateTypes] Error generating enums: $e',
      stackTrace: stackTrace,
    );
    rethrow;
  }
}
