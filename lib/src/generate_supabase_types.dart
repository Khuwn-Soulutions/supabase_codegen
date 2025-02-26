// Allow print statements for debugging
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

/// Supabase client instance to generate types.
late SupabaseClient client;

/// Generate Supabase types
Future<void> generateSupabaseTypes() async {
  final dotenv = DotEnv()..load();
  final hasKeys = dotenv.isEveryDefined(['SUPABASE_URL', 'SUPABASE_ANON_KEY']);
  if (!hasKeys) {
    print('[GenerateTypes] Missing Supabase keys in .env file');
    return;
  }

// Use your existing config
  final supabaseUrl = dotenv['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv['SUPABASE_ANON_KEY']!;
  print('[GenerateTypes] Starting type generation');

  client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  try {
    // Get table information from Supabase
    print('[GenerateTypes] Fetching schema info...');
    final response = await client.rpc<dynamic>('get_schema_info');

    // Debug raw response
    print('\n[GenerateTypes] Raw Schema Response: $response');
    print('Response type: ${response.runtimeType}');

    // Modified to handle direct List response
    final schemaData = (response is List
        ? response
        // Get data from the response if not a List
        // ignore: avoid_dynamic_calls
        : response.data) as List<Map<String, dynamic>>;

    if (schemaData.isEmpty) {
      throw Exception('Failed to fetch schema info: Empty response');
    }

    // Debug response data
    print('Count: ${schemaData.length}');
    if (schemaData.isNotEmpty) {
      print('First column sample:');
      print(schemaData.first);
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
    print('\n[GenerateTypes] Available tables:');
    for (final tableName in tables.keys) {
      print('  - $tableName');
    }

    // Create necessary directories
    await _createDirectories();

    // Generate database files
    await _generateDatabaseFiles(tables);

    // Generate schema files
    await _generateSchemaFiles(tables);

    print('[GenerateTypes] Successfully generated types');
  } catch (e) {
    print('[GenerateTypes] Error generating types: $e');
    rethrow;
  } finally {
    await client.dispose();
  }
}

Future<void> _createDirectories() async {
  final dirs = [
    'lib/backend/supabase/database/tables',
    'lib/backend/schema/structs',
    'lib/backend/schema/enums',
    'lib/backend/schema/util',
  ];

  for (final dir in dirs) {
    await Directory(dir).create(recursive: true);
  }
}

Future<void> _generateDatabaseFiles(
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  final directory = Directory('lib/backend/supabase/database/tables');

  // Generate database.dart
  final databaseFile = File('lib/backend/supabase/database/database.dart');
  final dbBuffer = StringBuffer()
    ..writeln("export 'package:latlng/latlng.dart';")
    ..writeln(
      "export 'package:supabase_flutter/supabase_flutter.dart' hide Provider;",
    )
    ..writeln("\nexport '../supabase.dart';")
    ..writeln("export 'row.dart';")
    ..writeln("export 'table.dart';\n");

  // Export all table files
  for (final tableName in tables.keys) {
    final fileName = tableName.toLowerCase();
    dbBuffer.writeln("export 'tables/$fileName.dart';");
  }

  await databaseFile.writeAsString(dbBuffer.toString());

  // Generate individual table files
  for (final tableName in tables.keys) {
    await _generateTableFile(tableName, tables[tableName]!, directory);
  }
}

Future<void> _generateTableFile(
  String tableName,
  List<Map<String, dynamic>> columns,
  Directory directory,
) async {
  print('\n[GenerateTableFile] Generating table file for: $tableName');

  final className = _formatClassName(tableName);
  final file = File('${directory.path}/${tableName.toLowerCase()}.dart');

  final buffer = StringBuffer()
    ..writeln("import '../database.dart';\n")

    // Generate Table class
    ..writeln(
      'class ${className}Table extends SupabaseTable<${className}Row> {',
    )
    ..writeln('  @override')
    ..writeln("  String get tableName => '$tableName';")
    ..writeln('\n  @override')
    ..writeln('  ${className}Row createRow(Map<String, dynamic> data) =>')
    ..writeln('      ${className}Row(data);')
    ..writeln('}\n')

    // Generate Row class
    ..writeln('class ${className}Row extends SupabaseDataRow {')
    ..writeln('  ${className}Row(super.data);\n')
    ..writeln('  @override')
    ..writeln('  SupabaseTable get table => ${className}Table();\n');

  // Generate getters and setters for each column
  for (final column in columns) {
    final fieldName = _formatFieldName(column['column_name'] as String);
    final columnName = column['column_name'] as String;
    final dartType = _getDartType(column);
    final isNullable = column['is_nullable'] == 'YES';
    final isArray = dartType.startsWith('List<');

    print('\n[GenerateTableFile] Processing column: $columnName');
    print('  UDT Name: $dartType');
    print('  Is Array: $isArray');
    print('  Field Name: $fieldName');

    if (isArray) {
      buffer
        ..writeln('  $dartType get $fieldName =>')
        ..writeln(
          "      getListField<${_getGenericType(dartType)}>('$columnName') "
          '?? const [];',
        )
        ..writeln(
          '  set $fieldName($dartType? value) => '
          "setListField<${_getGenericType(dartType)}>('$columnName', value);",
        );
    } else {
      if (isNullable) {
        buffer
          ..writeln('  $dartType? get $fieldName => '
              "getField<$dartType>('$columnName');")
          ..writeln('  set $fieldName($dartType? value) => '
              "setField<$dartType>('$columnName', value);");
      } else {
        buffer
          ..writeln('  $dartType get $fieldName => '
              "getField<$dartType>('$columnName')!;")
          ..writeln('  set $fieldName($dartType value) => '
              "setField<$dartType>('$columnName', value);");
      }
    }
    buffer.writeln(); // Single newline between field pairs
  }

  buffer.writeln('}');
  await file.writeAsString(buffer.toString());
}

Future<void> _generateSchemaFiles(
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  final directory = Directory('lib/backend/schema');
  final enumsDir = Directory('${directory.path}/enums');
  await enumsDir.create(recursive: true);

  // Generate enums_supa.dart
  await _generateEnumsFile(tables, enumsDir);

  print('[GenerateTypes] Successfully generated enums');
}

Future<void> _generateEnumsFile(
  Map<String, List<Map<String, dynamic>>> tables,
  Directory enumsDir,
) async {
  final enumFile = File('${enumsDir.path}/enums_supa.dart');
  final buffer = StringBuffer()

    // Add header comment and imports
    ..writeln(
      '// Do not edit this file. It is automatically generated by Supabase.',
    )
    ..writeln(
      '// If you need to add a new enum, add it /core/enums/core_enums.dart\n',
    )
    ..writeln("import 'package:collection/collection.dart';\n");

  // Fetch enum types from database
  print('[GenerateTypes] Fetching enum types from database...');

  try {
    // Query to get all enum types and their values
    print('[GenerateTypes] Executing RPC call to get_enum_types...');
    final response = await client.rpc<dynamic>('get_enum_types');

    // Modified to handle direct List response
    // ignore: avoid_dynamic_calls
    final enumData = (response is List ? response : response.data)
        as List<Map<String, dynamic>>;

    print('[GenerateTypes] Raw enum response data:');
    print(enumData);

    final enums = <String, List<String>>{};

    // Process the response data
    print('\n[GenerateTypes] Processing enum types:');
    for (final row in enumData) {
      final enumName = row['enum_name'] as String;
      final enumValue = (row['enum_value'] as String).replaceAll('/', '_');

      print('  Found enum: $enumName with value: $enumValue');

      if (!enums.containsKey(enumName)) {
        enums[enumName] = [];
        print('  Created new enum list for: $enumName');
      }
      enums[enumName]!.add(enumValue);
    }

    print('\n[GenerateTypes] Final processed enums:');
    enums.forEach((key, values) {
      print('  $key: ${values.join(', ')}');
    });

    // Generate each enum
    print('\n[GenerateTypes] Generating enum definitions:');
    enums.forEach((enumName, values) {
      // Format enum name to PascalCase and remove Enum suffix
      final formattedEnumName = enumName
          .split('_')
          .map(
            (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
          )
          .join()
          .replaceAll(RegExp(r'Enum$'), '');

      print('  Processing: $enumName -> $formattedEnumName');

      buffer.writeln('enum $formattedEnumName {');
      for (final value in values) {
        buffer.writeln('  $value,');
      }
      buffer.writeln('}\n');
    });

    // Add extension methods
    buffer.writeln('''
extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {''');

    // Generate deserialize cases
    enums.forEach((enumName, values) {
      final formattedEnumName = enumName
          .split('_')
          .map(
            (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
          )
          .join()
          .replaceAll(RegExp(r'Enum$'), '');

      buffer.writeln('''
    case ($formattedEnumName):
      return $formattedEnumName.values.deserialize(value) as T?;''');
    });

    buffer.writeln('''
    default:
      return null;
  }
}
''');

    await enumFile.writeAsString(buffer.toString());
    print('[GenerateTypes] Generated enums_supa.dart successfully');

    // Print final generated content
    print('\n[GenerateTypes] Generated enum content:');
    print(await enumFile.readAsString());
  } catch (e, stackTrace) {
    print('[GenerateTypes] Error generating enums: $e');
    print('[GenerateTypes] Stack trace: $stackTrace');
    rethrow;
  } finally {
    await client.dispose();
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
    default:
      if (dartType.startsWith('List<')) {
        return 'const []';
      }
      return 'null';
  }
}

/// Helper to get the parameter type for a given Dart type.
String getParamType(String dartType) {
  switch (dartType) {
    case 'int':
    case 'double':
    case 'bool':
    case 'String':
    case 'DateTime':
      return dartType;

    default:
      if (dartType.startsWith('List<')) {
        return 'DataStruct';
      }
      return 'String';
  }
}

/// Helper to deserialize a field for a [column].
String deserializeField(Map<String, dynamic> column) {
  final dartType = _getDartType(column);
  final columnName = column['column_name'] as String;

  if (dartType.startsWith('List<')) {
    return "getListField(data['$columnName'])";
  } else if (dartType == 'int' || dartType == 'double') {
    return "castToType<$dartType>(data['$columnName'])";
  } else if (dartType == 'DateTime') {
    return "data['$columnName'] as DateTime?";
  } else {
    return "data['$columnName'] as $dartType?";
  }
}

String _formatClassName(String tableName) {
  return tableName
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join();
}

String _formatFieldName(String columnName) {
  final words = columnName.split('_');
  return words[0].toLowerCase() +
      words
          .sublist(1)
          .map(
            (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
          )
          .join();
}

String _getDartType(Map<String, dynamic> column) {
  final postgresType = column['data_type'] as String;
  final udtName = column['udt_name'] as String? ?? '';

  // Improved array detection
  final isArray = udtName.startsWith('_') ||
      postgresType.endsWith('[]') ||
      postgresType.toUpperCase() == 'ARRAY' ||
      column['is_array'] == true;

  // Get base type for arrays
  String baseType;
  if (isArray) {
    if (udtName.startsWith('_')) {
      baseType = _getBaseDartType(udtName.substring(1));
    } else if (column['element_type'] != null) {
      baseType = _getBaseDartType(column['element_type'] as String);
    } else {
      baseType = _getBaseDartType(postgresType.replaceAll('[]', ''));
    }
    return 'List<$baseType>';
  }

  // Non-array types
  return _getBaseDartType(postgresType);
}

String _getBaseDartType(String postgresType) {
  switch (postgresType) {
    /// String
    case 'text':
    case 'varchar':
    case 'char':
    case 'uuid':
    case 'character varying':
    case 'name':
    case 'bytea':
      return 'String';

    /// Integer
    case 'int2':
    case 'int4':
    case 'int8':
    case 'integer':
    case 'bigint':
      return 'int';

    /// Double
    case 'float4':
    case 'float8':
    case 'decimal':
    case 'numeric':
    case 'double precision':
      return 'double';

    /// Bool
    case 'bool':
    case 'boolean':
      return 'bool';

    /// DateTime
    case 'timestamp':
    case 'timestamptz':
    case 'timestamp with time zone':
    case 'timestamp without time zone':
      return 'DateTime';

    /// Map
    case 'json':
    case 'jsonb':
      return 'Map<String, dynamic>';

    /// Enum
    case 'user-defined':
      return 'String'; // For enums

    /// Default
    default:
      return 'String';
  }
}

// Helper to extract generic type from List<T>
String _getGenericType(String listType) {
  final match = RegExp('List<(.+)>').firstMatch(listType);
  return match?.group(1) ?? 'dynamic';
}
