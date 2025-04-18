import 'dart:convert';
import 'dart:io';
import 'package:change_case/change_case.dart';
import 'package:meta/meta.dart';

import 'package:supabase_codegen/src/generator/generator.dart';

/// Generate the complete table file for the table with [tableName] with
/// [columns] to be written in the given [directory], considering the provided
/// [fieldNameTypeMap]
// coverage:ignore-start
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
  writeImports(buffer);

  /// Generate Table class
  writeTableClass(
    buffer: buffer,
    tableName: tableName,
    classDesc: classDesc,
    tableClass: tableClass,
    rowClass: rowClass,
  );

  /// Generate Row class
  writeRowClass(
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
@visibleForTesting
void writeImports(StringBuffer buffer) {
  writeHeader(buffer);

  final packageName = 'supabase_codegen${forFlutterUsage ? '_flutter' : ''}';

  /// Write imports
  buffer
    ..writeln("import 'package:$packageName/$packageName.dart';")
    ..writeln('// Import enums if needed')
    ..writeln('// ignore: unused_import, always_use_package_imports')
    ..writeln("import '../database.dart';")
    ..writeln();
}
// coverage:ignore-end

/// Generate the table class
@visibleForTesting
void writeTableClass({
  required StringBuffer buffer,
  required String tableName,
  required String classDesc,
  required String tableClass,
  required String rowClass,
}) {
  logger.i('Creating table class for: $tableName');

  final supabaseTable = 'Supabase${forFlutterUsage ? 'Flutter' : ''}Table';

  /// Create the table class
  buffer
    ..writeln('/// $classDesc Table')
    ..writeln('class $tableClass extends $supabaseTable<$rowClass> {')
    ..writeln('  /// Table Name')
    ..writeln('  @override')
    ..writeln("  String get tableName => '$tableName';")
    ..writeln()
    ..writeln('    /// Create a [$rowClass] from the [data] provided')
    ..writeln('  @override')
    ..writeln('  $rowClass createRow(Map<String, dynamic> data) =>')
    ..writeln('      $rowClass.fromJson(data);')
    ..writeln('}')
    ..writeln();
}

/// Write the row class
@visibleForTesting
void writeRowClass({
  required List<MapEntry<String, ColumnData>> entries,
  required StringBuffer buffer,
  required String className,
  required String classDesc,
  required String rowClass,
  required FieldNameTypeMap fieldNameTypeMap,
  required String tableClass,
}) {
  logger.i('Creating row class for: $className');

  final rowSuperClass = 'Supabase${forFlutterUsage ? 'Flutter' : ''}DataRow';

  /// Start the row class
  buffer
    ..writeln('/// $classDesc Row')
    ..writeln('class $rowClass extends $rowSuperClass {')
    ..writeln('  /// $classDesc Row')
    ..writeln('  $rowClass({');

  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :defaultValue,
      :columnName,
      :isArray,
      :isEnum
    ) = entry.value;
    final fieldName = entry.key;
    final isOptional = isNullable || hasDefault;
    final qualifier = isOptional ? '' : 'required ';
    final question = isOptional ? '?' : '';
    buffer.writeln('    $qualifier$dartType$question $fieldName,');
  }

  /// Write redirect constructor
  buffer.writeln('  }): super({');
  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :defaultValue,
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
      "    $ifNull'$columnName': supaSerialize($fieldName),",
    );
  }

  /// Close the constructor
  buffer
    ..writeln('  });')
    ..writeln()
    ..writeln('  /// $classDesc Row')
    ..writeln('  const $rowClass._(super.data);')
    ..writeln()

    /// Create the row from a json map
    ..writeln('  /// Create $classDesc Row from a [data] map')
    ..writeln('  factory $rowClass.fromJson(Map<String, dynamic> data) => '
        '$rowClass._(data.cleaned);');

  // Generate getters and setters for each column
  writeFields(
    fieldNameTypeMap: fieldNameTypeMap,
    buffer: buffer,
    tableClass: tableClass,
  );
  // Write copyWith
  writeCopyWith(buffer: buffer, entries: entries, rowClass: rowClass);

  /// Close the class
  buffer
    ..writeln('}')
    ..writeln();
}

/// Generate getters and setters for each column (field) in row
@visibleForTesting
void writeFields({
  required FieldNameTypeMap fieldNameTypeMap,
  required StringBuffer buffer,
  required String tableClass,
}) {
  /// Write the table getter
  buffer
    ..writeln('  /// Get the Json representation of the row')
    ..writeln('  Map<String, dynamic> toJson() => data;')
    ..writeln()
    ..writeln('  /// Get the [SupabaseTable] for this row')
    ..writeln('  @override')
    ..writeln('  SupabaseTable get table => $tableClass();')
    ..writeln();

  for (final entry in fieldNameTypeMap.entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :defaultValue,
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
    final fallbackValue = hasDefault
        ? ', defaultValue: ${getDefaultValue(
            dartType,
            defaultValue: defaultValue,
            isEnum: isEnum,
          )}'
        : '';
    if (isArray) {
      final genericType = getGenericType(dartType);
      buffer
        ..writeln('  $dartType get $fieldName => '
            'getListField<$genericType>($fieldColumnName$fallbackValue);')
        ..writeln(
          '  set $fieldName($dartType? value) => '
          'setListField<$genericType>($fieldColumnName, value);',
        );
    } else {
      final isOptional = isNullable && !hasDefault;
      final question = isOptional ? '?' : '';
      final bang = isOptional ? '' : '!';
      buffer
        ..writeln(
          '  $dartType$question get $fieldName => '
          'getField<$dartType>('
          '$fieldColumnName$enumValues$fallbackValue'
          ')$bang;',
        )
        ..writeln('  set $fieldName($dartType$question value) => '
            'setField<$dartType>($fieldColumnName, value);');
    }
    buffer.writeln(); // Single newline between field pairs
  }
}

/// Write the copy with block
@visibleForTesting
void writeCopyWith({
  required StringBuffer buffer,
  required List<MapEntry<String, ColumnData>> entries,
  required String rowClass,
}) {
  /// Write the copyWith method
  buffer
    ..writeln('  /// Make a copy of the current [$rowClass] ')
    ..writeln('  /// overriding the provided fields')
    ..writeln('  $rowClass copyWith({');

  /// All fields as optional
  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :defaultValue,
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
    ..writeln('    $rowClass.fromJson({');

  /// Overwrite the current data value with the incoming value
  for (final entry in entries) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :defaultValue,
      :columnName,
      :isArray,
      :isEnum
    ) = entry.value;
    final fieldName = entry.key;

    buffer.writeln(
      "      '$columnName': supaSerialize($fieldName) "
      "?? data['$columnName'],",
    );
  }

  buffer.writeln('    });');
}

/// Helper to get the default value for a given Dart type.
@visibleForTesting
String getDefaultValue(
  String dartType, {
  dynamic defaultValue,
  bool isEnum = false,
}) {
  final fallback = defaultValue
          ?.toString()
          // Serparate value from type
          .split('::')
          .first
          // Remove all single quotes
          .replaceAll("'", '')
          // Remove all functions
          .replaceAll(RegExp(r'\w+\(\)'), '') ??
      '';
  final fallbackValue = fallback.isNotEmpty ? fallback : null;

  logger.d(
    'Default value: $defaultValue, type: $dartType, fallback: $fallbackValue',
  );

  switch (dartType) {
    case 'int':
      return fallbackValue ?? '0';
    case 'double':
      return fallbackValue ?? '0.0';
    case 'bool':
      return fallbackValue ?? 'false';
    case 'String':
      return "'${fallbackValue ?? ""}'";
    case 'DateTime':
      return DateTime.tryParse(fallbackValue ?? '') != null
          ? "DateTime.parse('$fallbackValue')"
          : 'DateTime.now()';
    default:
      // Enum
      if (isEnum) {
        return fallbackValue != null ? '$dartType.$fallbackValue' : 'null';
      }
      // List
      if (dartType.startsWith('List<')) {
        final genericType = getGenericType(dartType);
        // Replace the enclosing {} of sql list to get comma separated list
        final fallbackList =
            fallbackValue?.replaceAll(RegExp('[{}]'), '') ?? '';
        final values = fallbackList.isEmpty
            ? <String>[]
            : fallbackList
                .split(',')
                .map(
                  (item) => switch (genericType) {
                    'String' => "'$item'",
                    _ => item,
                  },
                )
                .toList();
        logger.d('Values: $values');

        return 'const <$genericType>[${values.join(', ')}]';
      }
      // Map
      if (dartType == 'Map<String, dynamic>') {
        return jsonDecode(fallbackValue ?? '') != null
            ? fallbackValue!.replaceAll('"', "'")
            : '{}';
      }

      return 'null';
  }
}
