import 'dart:io';

import '../src.dart';

Future<void> generateEnumsFile(
  Map<String, List<Map<String, dynamic>>> tables,
  Directory enumsDir,
) async {
  final enumFile = File('${enumsDir.path}/$enumsFileName.dart');
  // Add header comment and imports
  final buffer = StringBuffer()
    ..writeln(
      '// Ignore public member docs for generated file\n'
      '// ignore_for_file: public_member_api_docs\n',
    )
    ..writeln(
      '// Do not edit this file. It is automatically generated by Supabase CodeGen.\n',
    );

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
          response.data as List,
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

    logger.d('[GenerateTypes] Final processed enums:');
    enums.forEach((key, values) {
      logger.d('  $key: ${values.join(', ')}');
    });

    /// Function to convert [word] to TitleCase
    String toTitleCase(String word) =>
        word[0].toUpperCase() + word.substring(1).toLowerCase();

    // Generate each enum
    logger.d('[GenerateTypes] Generating enum definitions:');
    enums.forEach((enumName, values) {
      // Format enum name to PascalCase and remove Enum suffix
      final formattedEnumName = enumName
          .split('_')
          .map(toTitleCase)
          .join()
          .replaceAll(RegExp(r'Enum$'), '');

      logger.d('  Processing: $enumName -> $formattedEnumName');
      formattedEnums[enumName] = formattedEnumName;

      buffer.writeln('enum $formattedEnumName {');
      for (final value in values) {
        buffer.writeln('  $value,');
      }
      buffer.writeln('}');
    });

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
