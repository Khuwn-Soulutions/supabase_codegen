import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:meta/meta.dart';

import 'package:supabase_codegen/src/generator/generator.dart';

/// Table barrel file name
const tableBarrelFileName = '_tables.dart';

/// Generate the schema info
// coverage:ignore-start
Future<void> generateSchemaInfo() async {
  try {
    final tables = await getSchemaTables();

    // Create necessary directories
    await createDirectories();

    // Generate schema files
    await generateSchemaFiles(tables);

    // Generate database files
    await generateDatabaseFiles(tables);

    logger.i('[GenerateTypes] Successfully generated types');
  } catch (e) {
    logger.d('[GenerateTypes] Error generating types: $e');
    rethrow;
  } finally {
    await client.dispose();
  }
}
// coverage:ignore-end

/// Get the schema tables
@visibleForTesting
Future<Map<String, List<Map<String, dynamic>>>> getSchemaTables() async {
  // Get table information from Supabase
  logger.i('[GenerateTypes] Fetching schema info...');
  final response = await client.rpc<dynamic>('get_schema_info');

  // Debug raw response
  logger
    ..d('[GenerateTypes] Raw Schema Response: $response')
    ..d('Response type: ${response.runtimeType}');

  // Modified to handle direct List response
  final schemaData = List<Map<String, dynamic>>.from(
    response is List
        ? response
        // Get data from the response if not a List
        // ignore: avoid_dynamic_calls
        : response['data'] as List<dynamic>,
  );

  if (schemaData.isEmpty) {
    throw Exception('Failed to fetch schema info: Empty response');
  }

  // Debug response data
  logger.d('Table Count: ${schemaData.length}');
  if (schemaData.isNotEmpty) {
    logger
      ..d('First column sample:')
      ..d(schemaData.first);
  }

  // Group columns by table
  final tables = <String, List<Map<String, dynamic>>>{};
  for (final column in schemaData) {
    final tableName = column['table_name'] as String;

    if (!tableName.startsWith('_')) {
      tables[tableName] = [
        ...tables[tableName] ?? [],
        column,
      ];
    }
  }

  // After fetching schema info
  logger.d('\n[GenerateTypes] Available tables:');
  for (final tableName in tables.keys) {
    logger.d('  - $tableName');
  }

  return tables;
}

// coverage:ignore-start
/// Create the necessary directories
Future<void> createDirectories() async {
  final dirs = [
    'tables',
    'enums',
  ];

  for (final dir in dirs) {
    await Directory('$root/$dir').create(recursive: true);
  }
}

/// Generate the database files for the schema
Future<void> generateDatabaseFiles(
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  logger
    ..i('[GenerateDatabaseFiles] Generating database files...')
    ..d('Writing files to $root');

  final directory = Directory('$root/tables');

  // Generate individual table files
  await generateTables(tables, directory);

  // Generate table barrel file
  await generateTableBarrelFile(directory, tables);
}
// coverage:ignore-end

/// Generate the table barrel file in the provided [directory] for the
/// extracted [tables]
@visibleForTesting
Future<void> generateTableBarrelFile(
  Directory directory,
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  final tableBarrelFile = File('${directory.path}/$tableBarrelFileName');
  final tableBarrelBuffer = StringBuffer();

  writeHeader(tableBarrelBuffer);
  for (final tableName in tables.keys) {
    final fileName = tableName.toLowerCase();
    tableBarrelBuffer.writeln("export '$fileName.dart';");
  }
  writeFooter(tableBarrelBuffer);

  tableBarrelFile.writeAsStringSync(tableBarrelBuffer.toString());

  // Generate database.dart
  final databaseFile = File('$root/database.dart');
  final dbBuffer = StringBuffer();
  writeHeader(dbBuffer);
  dbBuffer
    ..writeln("export 'enums/$enumsFileName.dart';")
    ..writeln("export 'tables/$tableBarrelFileName';");
  writeFooter(dbBuffer);

  databaseFile.writeAsStringSync(dbBuffer.toString());
}

// coverage:ignore-start
/// Generate the [tables] as individual files in the provided [directory]
Future<void> generateTables(
  Map<String, List<Map<String, dynamic>>> tables,
  Directory directory,
) async {
  for (final tableName in tables.keys) {
    final columns = tables[tableName]!;

    // Generate a map of the field name to data for that field
    final fieldNameTypeMap = createFieldNameTypeMap(columns);

    await generateTableFile(
      tableName: tableName,
      columns: columns,
      directory: directory,
      fieldNameTypeMap: fieldNameTypeMap,
    );
  }
}
// coverage:ignore-end

/// Create a map of the field name to data for that field
@visibleForTesting
Map<String, ColumnData> createFieldNameTypeMap(
  List<Map<String, dynamic>> columns,
) {
  /// Store a map of the column name to type
  final fieldNameTypeMap = <String, ColumnData>{};
  for (final column in columns) {
    final columnName = column['column_name'] as String;
    final fieldName = columnName.toCamelCase();
    final dartType = getDartType(column);
    final isNullable = column['is_nullable'] == 'YES';
    final isArray = dartType.startsWith('List<');
    final defaultValue = column['column_default'];
    final hasDefault = defaultValue != null;
    final isEnum = formattedEnums[column['udt_name']] != null;

    final columnData = (
      dartType: dartType,
      isNullable: isNullable,
      hasDefault: hasDefault,
      defaultValue: defaultValue,
      columnName: columnName,
      isArray: isArray,
      isEnum: isEnum,
    );
    fieldNameTypeMap[fieldName] = columnData;

    logger
      ..d('[GenerateTableFile] Processing column: $columnName')
      ..d('  Column data: $columnData');
  }
  return fieldNameTypeMap;
}
