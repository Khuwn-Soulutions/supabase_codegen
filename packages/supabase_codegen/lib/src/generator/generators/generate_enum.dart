import 'dart:io';

import 'package:change_case/change_case.dart';

import 'package:supabase_codegen/src/generator/generator.dart';

/// Generate enums
Future<void> generateEnums(Directory enumsDir) async {
  final enumBarrelFile = File('${enumsDir.path}/$enumBarrelFileName.dart');
  // Add header comment and imports
  final buffer = StringBuffer();

  /// Write the header to the barrel file
  writeHeader(buffer);

  try {
    final enums = await processEnums();

    // Generate each enum
    logger.debug('[GenerateTypes] Generating enum definitions:');
    enums.forEach((enumName, values) async {
      final formattedEnumName = formattedEnums[enumName]!;
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

      /// Write file to disk only if the content has changed ignoring date
      writeFileIfChangedIgnoringDate(enumFile, enumBuffer);

      logger.info('[GenerateTypes] Generated enum file: $fileName');

      /// Write the filename to the main buffer file
      buffer.writeln("export '$fileName.dart';");
    });

    /// Write footer
    writeFooter(buffer);

    /// Write file to disk only if the content has changed ignoring date
    writeFileIfChangedIgnoringDate(enumBarrelFile, buffer);
    logger.info('[GenerateTypes] Generated enums file successfully');
  } catch (e, stackTrace) {
    logger.error(
      '[GenerateTypes] Error generating enums: $e',
      e,
      stackTrace,
    );
    rethrow;
  }
}

/// Retrieve the enums from the database schema
Future<Map<String, List<String>>> fetchEnums() async {
  // Fetch enum types from database
  logger.info('[GenerateTypes] Fetching enum types from database...');
  try {
    // Query to get all enum types and their values
    logger.debug('[GenerateTypes] Executing RPC call to get_enum_types...');
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
      ..debug('[GenerateTypes] Raw enum response data:')
      ..debug(enumData);

    final enums = <String, List<String>>{};

    // Process the response data
    logger.debug('[GenerateTypes] Processing enum types:');
    for (final row in enumData) {
      final enumName = row['enum_name'] as String;
      final enumValue = (row['enum_value'] as String).replaceAll('/', '_');

      logger.debug('  Found enum: $enumName with value: $enumValue');

      if (!enums.containsKey(enumName)) {
        enums[enumName] = [];
        logger.debug('  Created new enum list for: $enumName');
      }
      enums[enumName]!.add(enumValue);
    }
    return enums;
  } on Exception catch (e) {
    logger.error('[GenerateTypes] Error retrieving enums: $e');
    rethrow;
  }
}

/// Process the enums populating the [formattedEnums] and returning the
/// all enums as a map of the enum name to the list of values
Future<Map<String, List<String>>> processEnums([
  Map<String, List<String>>? enums,
]) async {
  try {
    /// Get the enums from the database if not set
    enums ??= await fetchEnums();

    // Generate each enum
    logger.debug('[GenerateTypes] Generating enum definitions:');
    enums.forEach((enumName, values) async {
      // Format enum name to PascalCase and remove Enum suffix
      final formattedEnumName = enumName
          .split('_')
          .map((word) => word.toTitleCase())
          .join()
          .replaceAll(RegExp(r'Enum$'), '');

      logger.debug('  Processing: $enumName -> $formattedEnumName');
      formattedEnums[enumName] = formattedEnumName;
    });
    logger.debug('[GenerateTypes] Formatted enums: $formattedEnums');
    return enums;
  } catch (e, stackTrace) {
    logger.error(
      '[GenerateTypes] Error while processing enums: $e',
      e,
      stackTrace,
    );
    rethrow;
  }
}
