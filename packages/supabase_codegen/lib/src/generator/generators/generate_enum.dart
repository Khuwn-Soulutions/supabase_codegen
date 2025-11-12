import 'dart:convert';
import 'dart:io';

import 'package:change_case/change_case.dart';

import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Generate enums list
Future<List<EnumConfig>> generateEnumConfigs() async {
  final enums = await processEnums();
  return enums.entries.map((entry) {
    final enumName = entry.key;
    final values = entry.value;
    final formattedEnumName = formattedEnums[enumName]!;
    return EnumConfig(
      enumName: enumName,
      formattedEnumName: formattedEnumName,
      values: values,
    );
  }).toList();
}

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
    logger.detail('Generating enum definitions:');
    final enumList = <Map<String, dynamic>>[];
    enums.forEach((enumName, values) async {
      final formattedEnumName = formattedEnums[enumName]!;
      final enumBuffer = StringBuffer();
      final fileName = formattedEnumName.toSnakeCase();
      final enumFile = File('${enumsDir.path}/$fileName.dart');
      enumList.add({
        'enumName': enumName,
        'formattedEnumName': formattedEnumName,
        'values': values,
      });

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

      logger.info('Generated enum file: $fileName');

      /// Write the filename to the main buffer file
      buffer.writeln("export '$fileName.dart';");
    });
    logger.detail(
      'Enum List: ${jsonEncode(enumList)}',
    );

    /// Write footer
    writeFooter(buffer);

    /// Write file to disk only if the content has changed ignoring date
    writeFileIfChangedIgnoringDate(enumBarrelFile, buffer);
    logger.info('Generated enums file successfully');
  } catch (e) {
    logger.err('Error generating enums: $e');
    rethrow;
  }
}

/// Retrieve the enums from the database schema
Future<Map<String, List<String>>> fetchEnums() async {
  // Fetch enum types from database
  final progress = logger.progress(
    'Fetching enum types from database...',
  );
  try {
    // Query to get all enum types and their values
    logger.detail('Executing RPC call to get_enum_types...');
    final response = await client.rpc<List<dynamic>>('get_enum_types');

    final enumData = List<Map<String, dynamic>>.from(response);

    logger
      ..detail('Raw enum response data:')
      ..detail(enumData.toString());

    final enums = <String, List<String>>{};

    // Process the response data
    logger.detail('Processing enum types:');
    for (final row in enumData) {
      final enumName = row['enum_name'] as String;
      final enumValue = (row['enum_value'] as String).replaceAll('/', '_');

      logger.detail('  Found enum: $enumName with value: $enumValue');

      if (!enums.containsKey(enumName)) {
        enums[enumName] = [];
        logger.detail('  Created new enum list for: $enumName');
      }
      enums[enumName]!.add(enumValue);
    }
    progress.complete('Database enums fetched');
    return enums;
  } on Exception catch (e) {
    progress.fail('Failed to fetch enums from database');
    logger.err('Error retrieving enums: $e');
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
    logger.detail('Generating enum definitions:');
    enums.forEach((enumName, values) async {
      // Format enum name to PascalCase and remove Enum suffix
      final formattedEnumName = enumName
          .split('_')
          .map((word) => word.toTitleCase())
          .join()
          .replaceAll(RegExp(r'Enum$'), '');

      logger.detail('  Processing: $enumName -> $formattedEnumName');
      formattedEnums[enumName] = formattedEnumName;
    });
    logger.detail('Formatted enums: $formattedEnums');
    return enums;
  } catch (e) {
    logger.err('Error while processing enums: $e');
    rethrow;
  }
}
