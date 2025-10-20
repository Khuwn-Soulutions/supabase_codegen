import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'package:supabase_codegen/src/generator/generator.dart';

/// Table barrel file name
const tableBarrelFileName = '_tables.dart';

/// Tables directory name
const tablesDirectoryName = 'tables';

/// Tables directory
final tablesDirectory = Directory(path.join(root, tablesDirectoryName));

/// Enums directory name
const enumsDirectoryName = 'enums';

/// Enums directory
final enumsDirectory = Directory(path.join(root, enumsDirectoryName));

/// Generate the schema info
// coverage:ignore-start
Future<void> generateSchemaInfo() async {
  try {
    // Create necessary directories
    await createDirectories();

    // Generate schema files
    await generateSchemaFiles();

    await generateSchemaTables();

    logger.info('[GenerateTypes] Successfully generated types');
  } catch (e) {
    logger.debug('[GenerateTypes] Error generating types: $e');
    rethrow;
  } finally {
    await client.dispose();
  }
}
// coverage:ignore-end

/// Generate tables for the schema
Future<void> generateSchemaTables() async {
  final tables = await getSchemaTables();
  // Generate database files
  await generateDatabaseFiles(tables);
}

/// Get the schema tables
Future<Map<String, List<Map<String, dynamic>>>> getSchemaTables() async {
  // Get table information from Supabase
  logger.info('[GenerateTypes] Fetching schema info...');
  final response = await client.rpc<dynamic>('get_schema_info');

  // Debug raw response
  logger
    ..debug('[GenerateTypes] Raw Schema Response: $response')
    ..debug('Response type: ${response.runtimeType}');

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
  logger.debug('Table Count: ${schemaData.length}');
  if (schemaData.isNotEmpty) {
    logger
      ..debug('First column sample:')
      ..debug(schemaData.first);
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
  logger.debug('\n[GenerateTypes] Available tables:');
  for (final tableName in tables.keys) {
    logger.debug('  - $tableName');
  }

  return tables;
}

// coverage:ignore-start
/// Create the necessary directories
Future<void> createDirectories({
  Directory? tablesDir,
  Directory? enumsDir,
}) async {
  final dirs = [
    tablesDir ?? tablesDirectory,
    enumsDir ?? enumsDirectory,
  ];

  for (final dir in dirs) {
    await dir.create(recursive: true);
  }
}

/// Generate the database files for the schema
Future<void> generateDatabaseFiles(
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  logger
    ..info('[GenerateDatabaseFiles] Generating database files...')
    ..debug('Writing files to $root');

  // Generate individual table files
  await generateTables(tables);

  // Generate table barrel file
  await generateTableBarrelFile(tables);
}
// coverage:ignore-end

/// Generate the table barrel file in the provided [directory] for the
/// extracted [tables]
@visibleForTesting
Future<void> generateTableBarrelFile(
  Map<String, List<Map<String, dynamic>>> tables, [
  Directory? directory,
]) async {
  final tablesDir = directory ?? tablesDirectory;
  final tableBarrelFile = File(path.join(tablesDir.path, tableBarrelFileName));
  final tableBarrelBuffer = StringBuffer();

  writeHeader(tableBarrelBuffer);
  for (final tableName in tables.keys) {
    final fileName = tableName.toLowerCase();
    tableBarrelBuffer.writeln("export '$fileName.dart';");
  }
  writeFooter(tableBarrelBuffer);

  writeFileIfChangedIgnoringDate(tableBarrelFile, tableBarrelBuffer);

  // Generate database.dart
  final databaseFile = File('$root/database.dart');
  final dbBuffer = StringBuffer();
  writeHeader(dbBuffer);
  dbBuffer
    ..writeln("export 'enums/$enumBarrelFileName.dart';")
    ..writeln("export 'tables/$tableBarrelFileName';");
  writeFooter(dbBuffer);

  writeFileIfChangedIgnoringDate(databaseFile, dbBuffer);
}

// coverage:ignore-start
/// Generate the [tables] as individual files in the provided [directory]
Future<void> generateTables(
  Map<String, List<Map<String, dynamic>>> tables, [
  Directory? directory,
]) async {
  final tablesDir = directory ?? tablesDirectory;
  for (final tableName in tables.keys) {
    final columns = tables[tableName]!;
    final tableOverrides = schemaOverrides[tableName];

    // Generate a map of the field name to data for that field
    final fieldNameTypeMap = createFieldNameTypeMap(
      columns,
      tableOverrides: tableOverrides,
    );

    await generateTableFile(
      tableName: tableName,
      columns: columns,
      directory: tablesDir,
      fieldNameTypeMap: fieldNameTypeMap,
    );
  }
}
// coverage:ignore-end

/// Create a map of the field name to data for that field
Map<String, ColumnData> createFieldNameTypeMap(
  List<Map<String, dynamic>> columns, {
  TableOverrides? tableOverrides,
}) {
  /// Store a map of the column name to type
  final fieldNameTypeMap = <String, ColumnData>{};
  for (final column in columns) {
    final columnName = column['column_name'] as String;
    final columnOverride = tableOverrides?[columnName];
    final fieldName = columnName.toCamelCase();
    final dartType = columnOverride?.dataType ?? getDartType(column);
    final isNullable =
        columnOverride?.isNullable ?? column['is_nullable'] == 'YES';
    final isArray = dartType.startsWith('List<');
    final defaultValue =
        columnOverride?.columnDefault ?? column['column_default'];
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
      ..debug('[GenerateTableFile] Processing column: $columnName')
      ..debug('  Column data: $columnData');
  }
  return fieldNameTypeMap;
}
