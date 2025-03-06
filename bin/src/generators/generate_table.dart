import 'dart:io';
import 'package:change_case/change_case.dart';

import '../src.dart';

Future<void> generateTableFile({
  required String tableName,
  required List<Map<String, dynamic>> columns,
  required Directory directory,
  required FieldNameTypeMap fieldNameTypeMap,
}) async {
  logger.i('[GenerateTableFile] Generating file for: $tableName');

  final className = tableName.toPascalCase();
  final tableClass = '${className}Table';
  final rowClass = '${className}Row';
  final classDesc = tableName.toCapitalCase();
  final file = File('${directory.path}/${tableName.toLowerCase()}.dart');
  final buffer = StringBuffer();

  // Convert the map to a list of entries sorted with the required items first
  final entries = fieldNameTypeMap.entries.toList()
    ..sort((a, b) {
      final aIsRequired = !a.value.isNullable && !a.value.hasDefault;
      final bIsRequired = !b.value.isNullable && !b.value.hasDefault;

      if (aIsRequired == bIsRequired) {
        // Keep original order if both are required or both are optional
        return 0;
      } else if (aIsRequired) {
        return -1; // Place required items first
      } else {
        return 1; // Place optional items after required items
      }
    });

  /// Write imports
  _writeImports(buffer);

  /// Generate Table class
  _writeTableClass(
    buffer: buffer,
    tableName: tableName,
    classDesc: classDesc,
    tableClass: tableClass,
    rowClass: rowClass,
  );

  /// Generate Row class
  _writeRowClass(
    entries: entries,
    buffer: buffer,
    className: className,
    classDesc: classDesc,
    rowClass: rowClass,
    fieldNameTypeMap: fieldNameTypeMap,
    tableClass: tableClass,
  );

  /// Write the footer
  writeFooter(buffer);

  /// Write the file to disk
  await file.writeAsString(buffer.toString());
}

/// Write the package imports
void _writeImports(StringBuffer buffer) {
  writeHeader(buffer);

  /// Write imports
  buffer
    ..writeln("import 'package:supabase_codegen/supabase_codegen.dart';")
    ..writeln('// Import enums if needed')
    ..writeln('// ignore: unused_import, always_use_package_imports')
    ..writeln("import '../database.dart';")
    ..writeln();
}

/// Generate the table class
void _writeTableClass({
  required StringBuffer buffer,
  required String tableName,
  required String classDesc,
  required String tableClass,
  required String rowClass,
}) {
  logger.i('Creating table class for: $tableName');

  /// Create the table class
  buffer
    ..writeln('/// $classDesc Table')
    ..writeln('class $tableClass extends SupabaseTable<$rowClass> {')
    ..writeln('  /// Table Name')
    ..writeln('  @override')
    ..writeln("  String get tableName => '$tableName';")
    ..writeln()
    ..writeln('    /// Create a [$rowClass] from the [data] provided')
    ..writeln('  @override')
    ..writeln('  $rowClass createRow(Map<String, dynamic> data) =>')
    ..writeln('      $rowClass(data);')
    ..writeln('}')
    ..writeln();
}

/// Write the row class
void _writeRowClass({
  required List<MapEntry<String, ColumnData>> entries,
  required StringBuffer buffer,
  required String className,
  required String classDesc,
  required String rowClass,
  required FieldNameTypeMap fieldNameTypeMap,
  required String tableClass,
}) {
  logger.i('Creating row class for: $className');

  /// Start the row class
  buffer
    ..writeln('/// $classDesc Row')
    ..writeln('class $rowClass extends SupabaseDataRow {')
    ..writeln('  /// $classDesc Row')
    ..writeln('  $rowClass({');

  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :columnName,
      :isArray,
      :isEnum
    ) = entry.value;
    final fieldName = entry.key;
    final isOptional = isNullable || hasDefault;
    final qualifier = isOptional ? '' : 'required';
    final question = isOptional ? '?' : '';
    buffer.writeln('    $qualifier $dartType$question $fieldName,');
  }

  /// Write redirect constructor
  buffer.writeln('  }): super({');
  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :columnName,
      :isArray,
      :isEnum
    ) = entry.value;
    final fieldName = entry.key;

    /// Do not set the value for optional fields in data
    /// This will ensure that they are registered as null in the database
    /// or the default value set within the database
    final isOptional = isNullable || hasDefault;
    final ifNull = isOptional ? 'if ($fieldName != null) ' : '';

    /// Write line to set the field in the data map to be sent to database
    buffer.writeln(
      "    $ifNull'$columnName': $fieldName${isEnum ? '.name' : ''},",
    );
  }

  /// Close the constructor
  buffer
    ..writeln('  });')
    ..writeln();

  // Generate getters and setters for each column
  _writeFields(
    fieldNameTypeMap: fieldNameTypeMap,
    buffer: buffer,
    tableClass: tableClass,
  );

  // Write copyWith
  _writeCopyWith(buffer: buffer, entries: entries, rowClass: rowClass);

  /// Close the class
  buffer
    ..writeln('}')
    ..writeln();
}

/// Generate getters and setters for each column (field) in row
void _writeFields({
  required FieldNameTypeMap fieldNameTypeMap,
  required StringBuffer buffer,
  required String tableClass,
}) {
  /// Write the table getter
  buffer
    ..writeln('  /// Get the [SupabaseTable] for this row')
    ..writeln('  @override')
    ..writeln('  SupabaseTable get table => $tableClass();')
    ..writeln();

  for (final entry in fieldNameTypeMap.entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :columnName,
      :isArray,
      :isEnum
    ) = entry.value;
    final fieldName = entry.key;

    final enumValues = isEnum ? ', enumValues: $dartType.values' : '';

    final fieldComment = fieldName.toCapitalCase();
    final fieldColumnName = '${fieldName}Field';

    /// Write static column name before fields
    buffer
      ..writeln('  /// $fieldComment field name')
      ..writeln("  static const String $fieldColumnName = '$columnName';")
      ..writeln()
      ..writeln('  /// $fieldComment');
    if (isArray) {
      final genericType = getGenericType(dartType);
      buffer
        ..writeln('  $dartType get $fieldName => '
            'getListField<$genericType>($fieldColumnName);')
        ..writeln(
          '  set $fieldName($dartType? value) => '
          'setListField<$genericType>($fieldColumnName, value);',
        );
    } else {
      final isOptional = isNullable && !hasDefault;
      final question = isOptional ? '?' : '';
      final bang = isOptional ? '' : '!';
      final defaultValue =
          hasDefault ? ', defaultValue: ${getDefaultValue(dartType)}' : '';
      buffer
        ..writeln(
          '  $dartType$question get $fieldName => '
          'getField<$dartType>($fieldColumnName$enumValues$defaultValue)$bang;',
        )
        ..writeln('  set $fieldName($dartType$question value) => '
            'setField<$dartType>($fieldColumnName, value);');
    }
    buffer.writeln(); // Single newline between field pairs
  }
}

/// Write the copy with block
void _writeCopyWith({
  required StringBuffer buffer,
  required List<MapEntry<String, ColumnData>> entries,
  required String rowClass,
}) {
  /// Write the copyWith method
  buffer
    ..writeln('/// Make a copy of the current [$rowClass] overriding '
        'the provided fields')
    ..writeln('  $rowClass copyWith({');

  /// All fields as optional
  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :columnName,
      :isArray,
      :isEnum
    ) = entry.value;
    final fieldName = entry.key;

    /// Write line to get the field as parameter
    buffer.writeln(
      '    $dartType? $fieldName,',
    );
  }

  /// Close method
  buffer
    ..writeln('  }) =>')
    ..writeln('    $rowClass({');

  /// Overwrite the current data value with the incoming value
  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :columnName,
      :isArray,
      :isEnum
    ) = entry.value;
    final fieldName = entry.key;
    final enumName = isEnum ? '?.name' : '';

    buffer.writeln(
      "      '$columnName': $fieldName$enumName ?? data['$columnName'],",
    );
  }

  buffer.writeln('    });');
}
