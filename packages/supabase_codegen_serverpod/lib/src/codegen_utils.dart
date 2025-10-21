import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:meta/meta.dart';
import 'package:pluralize/pluralize.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Supabase code generator serverpod utils class
@visibleForTesting
class SupabaseCodeGenServerpodUtils extends SupabaseCodeGeneratorUtils {
  /// Constructor
  const SupabaseCodeGenServerpodUtils() : super();

  /// Tables directory
  Directory get tablesDirectory => Directory('$root/tables');

  /// Enums directory
  Directory get enumsDirectory => Directory('$root/enums');

  /// Comment prefix
  static const String commentPrefix = '##';

  /// Generated file type
  static const String fileType = 'spy';

  /// Generate schema info
  @override
  @visibleForTesting
  Future<void> generateSchema({
    Directory? enumsDir,
    Directory? tablesDir,
    Map<String, List<String>>? enums,
    Map<String, List<Map<String, dynamic>>>? schemaTables,
  }) async {
    /// Create necessary directories
    await createDirectories(
      enumsDir: enumsDir,
      tablesDir: tablesDir,
    );

    /// Generate enums
    await generateEnumFiles(enums);

    /// Generate table files
    await generateTableFiles(schemaTables);

    logger.info('Successfully generated schema');
  }

  /// Write the spy yaml file header
  void writeSpyHeader(StringBuffer buffer) =>
      writeHeader(buffer, skipIgnore: true, commentPrefix: commentPrefix);

  /// Write the spy yaml file footer
  void writeSpyFooter(StringBuffer buffer) =>
      writeFooter(buffer, commentPrefix: commentPrefix);

  /// Generate enum files
  Future<void> generateEnumFiles([Map<String, List<String>>? enums]) async {
    logger.info('Generating enums...');

    /// Process the enums
    final enumData = await processEnums(enums);
    logger.info('Got enum data: $enumData');

    /// Generate enum files
    enumData.forEach((enumName, values) async {
      final formattedEnumName = formattedEnums[enumName];

      // coverage:ignore-start
      if (formattedEnumName == null) {
        throw Exception(
          'Enum with name: $enumName not found in formattedEnums',
        );
      }

      // coverage:ignore-end

      final enumBuffer = StringBuffer();
      final fileName = formattedEnumName.toSnakeCase();

      /// Add header
      writeSpyHeader(enumBuffer);

      enumBuffer
        ..writeln('enum: $formattedEnumName')
        ..writeln('serialized: byName')
        ..writeln('values:');

      for (final value in values) {
        enumBuffer.writeln(' - $value');
      }

      /// Add footer
      writeSpyFooter(enumBuffer);

      /// Write file to disk only if the content has changed ignoring date
      final enumFile = File('${enumsDirectory.path}/$fileName.$fileType');
      writeFileIfChangedIgnoringDate(enumFile, enumBuffer);
    });
  }

  /// Generate table files
  Future<void> generateTableFiles([
    Map<String, List<Map<String, dynamic>>>? schemaTables,
  ]) async {
    logger.info('Generating schema...');

    // coverage:ignore-start
    final tables = (schemaTables ?? await getSchemaTables())
      /// Remove all serverpod tables
      ..removeWhere((key, value) => key.startsWith('serverpod_'));

    // coverage:ignore-end
    logger.debug('Got tables: $tables');

    for (final tableName in tables.keys) {
      final columns = tables[tableName]!;
      final tableOverrides = schemaOverrides[tableName];

      // Generate a map of the field name to data for that field
      final fieldNameTypeMap = createFieldNameTypeMap(
        columns,
        tableOverrides: tableOverrides,
      );
      logger.debug('Field name type map for $tableName: $fieldNameTypeMap');

      generateModel(tableName, fieldNameTypeMap);
    }
  }

  /// Generate model
  void generateModel(String tableName, FieldNameTypeMap fieldNameTypeMap) {
    logger.info('Generating model for $tableName');
    final buffer = StringBuffer();
    final className = Pluralize().singular(tableName.toPascalCase());
    writeSpyHeader(buffer);
    buffer
      ..writeln('class: $className')
      ..writeln('table: $tableName')
      ..writeln('fields:');

    for (final entry in fieldNameTypeMap.sortedEntries) {
      final (
        :dartType,
        :isNullable,
        :hasDefault,
        :defaultValue,
        :columnName,
        :isArray,
        :isEnum,
      ) = entry.value;
      final fieldName = entry.key;
      final isOptional = isNullable || hasDefault;
      final question = isOptional ? '?' : '';
      final type = dartType.isDynamic ? 'Object' : dartType;

      buffer.writeln('  $fieldName: $type$question');
    }

    // Write the footer
    writeSpyFooter(buffer);

    final filename = tableName.toSnakeCase();
    final file = File('${tablesDirectory.path}/$filename.$fileType');
    writeFileIfChangedIgnoringDate(file, buffer);
  }
}
