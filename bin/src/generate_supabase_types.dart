import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

import 'src.dart';

/// Supabase client instance to generate types.
late SupabaseClient client;

/// Root directory path for generating files
late String root;

/// Enums file name
const enumsFileName = 'supabase_enums';

/// Map of enum type to formatted name
final formattedEnums = <String, String>{};

/// Column data type
typedef ColumnData = ({
  String dartType,
  bool isNullable,
  bool hasDefault,
  String columnName,
  bool isArray,
  bool isEnum,
});

/// Field name type map
typedef FieldNameTypeMap = Map<String, ColumnData>;

/// Generate Supabase types
Future<void> generateSupabaseTypes({
  required String envFilePath,
  required String outputFolder,
  String tag = '',
}) async {
  /// Set root folder
  root = outputFolder;

  /// Load env keys
  final dotenv = DotEnv()..load([envFilePath]);
  final hasKeys = dotenv.isEveryDefined(['SUPABASE_URL', 'SUPABASE_ANON_KEY']);
  if (!hasKeys) {
    throw Exception(
      '[GenerateTypes] Missing Supabase keys in $envFilePath file',
    );
  }

  // Get the config from env
  final supabaseUrl = dotenv['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv['SUPABASE_ANON_KEY']!;
  logger.i('[GenerateTypes] Starting type generation');

  client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  try {
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
          : response.data as List<dynamic>,
    );

    if (schemaData.isEmpty) {
      throw Exception('Failed to fetch schema info: Empty response');
    }

    // Debug response data
    logger.d('Count: ${schemaData.length}');
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

    // Create necessary directories
    await _createDirectories();

    // Generate schema files
    await generateSchemaFiles(tables);

    // Generate database files
    await _generateDatabaseFiles(tables, tag: tag);

    logger.i('[GenerateTypes] Successfully generated types');
  } catch (e) {
    logger.d('[GenerateTypes] Error generating types: $e');
    rethrow;
  } finally {
    await client.dispose();
  }
}

Future<void> _createDirectories() async {
  final dirs = [
    '$root/tables',
    '$root/enums',
  ];

  for (final dir in dirs) {
    await Directory(dir).create(recursive: true);
  }
}

Future<void> _generateDatabaseFiles(
  Map<String, List<Map<String, dynamic>>> tables, {
  String tag = '',
}) async {
  logger
    ..i('[GenerateDatabaseFiles] Generating database files...')
    ..d('Writing files to $root');

  final directory = Directory('$root/tables');

  // Generate database.dart
  final databaseFile = File('$root/database.dart');
  final dbBuffer = StringBuffer()
    ..writeln("export 'enums/$enumsFileName.dart';");

  // Export all table files
  for (final tableName in tables.keys) {
    final fileName = tableName.toLowerCase();
    dbBuffer.writeln("export 'tables/$fileName.dart';");
  }

  await databaseFile.writeAsString(dbBuffer.toString());

  // Generate individual table files
  for (final tableName in tables.keys) {
    final columns = tables[tableName]!;

    /// Store a map of the column name to type
    final fieldNameTypeMap = <String, ColumnData>{};

    // Generate a map of the field name to data for that field
    for (final column in columns) {
      final columnName = column['column_name'] as String;
      final fieldName = columnName.toCamelCase();
      final dartType = getDartType(column);
      final isNullable = column['is_nullable'] == 'YES';
      final isArray = dartType.startsWith('List<');
      final hasDefault = column['column_default'] != null;
      final isEnum = formattedEnums[column['udt_name']] != null;

      final columnData = (
        dartType: dartType,
        isNullable: isNullable,
        hasDefault: hasDefault,
        columnName: columnName,
        isArray: isArray,
        isEnum: isEnum,
      );
      fieldNameTypeMap[fieldName] = columnData;

      logger
        ..d('[GenerateTableFile] Processing column: $columnName')
        ..d('  Column data: $columnData');
    }

    await generateTableFile(
      tableName: tableName,
      columns: columns,
      directory: directory,
      fieldNameTypeMap: fieldNameTypeMap,
      tag: tag,
    );
  }
}

/// Helper to get the default value for a given Dart type.
String getDefaultValue(String dartType) {
  switch (dartType) {
    case 'int':
      return '0';
    case 'double':
      return '0.0';
    case 'bool':
      return 'false';
    case 'String':
      return "''";
    case 'DateTime':
      return 'DateTime.now()';
    default:
      if (dartType.startsWith('List<')) {
        return 'const []';
      }
      return 'null';
  }
}
