// Allow print statements for debugging
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

/// Supabase client instance to generate types.
late SupabaseClient client;

/// Root directory path for generating files
late String root;

/// Enums file name
const enumsFileName = 'supabase_enums';

/// Formatted enums
final formattedEnums = <String, String>{};

/// Column data type
typedef ColumnData = ({
  String dartType,
  bool isNullable,
  bool hasDefault,
  String columnName,
  bool isArray,
});

/// Field name type map
typedef FieldNameTypeMap = Map<String, ColumnData>;

/// Generate Supabase types
Future<void> generateSupabaseTypes({
  required String envFilePath,
  required String outputFolder,
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

    // Generate schema files
    await _generateSchemaFiles(tables);

    // Generate database files
    await _generateDatabaseFiles(tables);

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
    '$root/tables',
    '$root/enums',
  ];

  for (final dir in dirs) {
    await Directory(dir).create(recursive: true);
  }
}

Future<void> _generateDatabaseFiles(
  Map<String, List<Map<String, dynamic>>> tables,
) async {
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

    // Generate getters and setters for each column
    for (final column in columns) {
      final columnName = column['column_name'] as String;
      final fieldName = columnName.toCamelCase();
      final dartType = _getDartType(column);
      final isNullable = column['is_nullable'] == 'YES';
      final isArray = dartType.startsWith('List<');
      final hasDefault = column['column_default'] != null;
      fieldNameTypeMap[fieldName] = (
        dartType: dartType,
        isNullable: isNullable,
        hasDefault: hasDefault,
        columnName: columnName,
        isArray: isArray,
      );

      print('\n[GenerateTableFile] Processing column: $columnName');
      print('  UDT Name: $dartType');
      print('  Is Array: $isArray');
      print('  Field Name: $fieldName');
    }

    await _generateTableFile(
      tableName: tableName,
      columns: columns,
      directory: directory,
      fieldNameTypeMap: fieldNameTypeMap,
    );
  }
}

Future<void> _generateTableFile({
  required String tableName,
  required List<Map<String, dynamic>> columns,
  required Directory directory,
  required FieldNameTypeMap fieldNameTypeMap,
}) async {
  print('\n[GenerateTableFile] Generating table file for: $tableName');

  final className = tableName.toPascalCase();
  final classDesc = tableName.toCapitalCase();
  final file = File('${directory.path}/${tableName.toLowerCase()}.dart');

  final buffer = StringBuffer()
    ..writeln("import 'package:supabase_codegen/supabase_codegen.dart';")
    ..writeln('// Import enums if needed')
    ..writeln('// ignore: unused_import, always_use_package_imports')
    ..writeln("import '../database.dart';")
    ..writeln()

    // Generate Table class
    ..writeln('/// $classDesc Table')
    ..writeln(
      'class ${className}Table extends SupabaseTable<${className}Row> {',
    )
    ..writeln('  /// Table Name')
    ..writeln('  @override')
    ..writeln("  String get tableName => '$tableName';")
    ..writeln()
    ..writeln('    /// Create a [${className}Row] from the [data] provided')
    ..writeln('  @override')
    ..writeln('  ${className}Row createRow(Map<String, dynamic> data) =>')
    ..writeln('      ${className}Row(data);')
    ..writeln('}')
    ..writeln()

    // Generate Row class
    ..writeln('/// $classDesc Row')
    ..writeln('class ${className}Row extends SupabaseDataRow {')
    ..writeln('  /// $classDesc Row')
    ..writeln('  const ${className}Row(super.data);')
    ..writeln()

    /// Write constructor to use fields
    ..writeln('  /// Construct $classDesc Row using fields')
    // ..writeln('  // ignore: sort_constructors_first')
    ..writeln('  factory ${className}Row.withFields({');

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

  /// Write fields
  for (final entry in entries) {
    final (:dartType, :isNullable, :hasDefault, :columnName, :isArray) =
        entry.value;
    final fieldName = entry.key;
    final isOptional = isNullable || hasDefault;
    final qualifier = isOptional ? '' : 'required';
    final question = isOptional ? '?' : '';
    buffer.writeln('    $qualifier $dartType$question $fieldName,');
  }

  /// Write redirect constructor
  buffer.writeln('  })  => ${className}Row({');
  for (final entry in entries) {
    final (:dartType, :isNullable, :hasDefault, :columnName, :isArray) =
        entry.value;
    final fieldName = entry.key;

    /// Do not set the value for optional fields in data
    /// This will ensure that they are registered as null in the database
    /// or the default value set within the database
    final isOptional = isNullable || hasDefault;
    final ifNull = isOptional ? 'if ($fieldName != null) ' : '';

    /// Write line to set the field in the data map to be sent to database
    buffer.writeln("    $ifNull'$columnName': $fieldName,");
  }

  /// Close the constructor and class
  buffer
    ..writeln('  });')
    ..writeln()
    ..writeln('  /// Get the [SupabaseTable] for this row')
    ..writeln('  @override')
    ..writeln('  SupabaseTable get table => ${className}Table();\n');

  // Generate getters and setters for each column
  for (final entry in fieldNameTypeMap.entries) {
    final (:dartType, :isNullable, :hasDefault, :columnName, :isArray) =
        entry.value;
    final fieldName = entry.key;

    print('\n[GenerateTableFile] Processing column: $columnName');
    print('  UDT Name: $dartType');
    print('  Is Array: $isArray');
    print('  Field Name: $fieldName');

    buffer.writeln('  /// ${fieldName.toCapitalCase()}');
    if (isArray) {
      final genericType = _getGenericType(dartType);
      buffer
        ..writeln('  $dartType get $fieldName => '
            "getListField<$genericType>('$columnName');")
        ..writeln(
          '  set $fieldName($dartType? value) => '
          "setListField<$genericType>('$columnName', value);",
        );
    } else {
      final isOptional = isNullable && !hasDefault;
      final question = isOptional ? '?' : '';
      final hashBang = isOptional ? '' : '!';
      final defaultValue =
          hasDefault ? ', defaultValue: ${getDefaultValue(dartType)}' : '';
      buffer
        ..writeln('  $dartType$question get $fieldName => '
            "getField<$dartType>('$columnName'$defaultValue)$hashBang;")
        ..writeln('  set $fieldName($dartType$question value) => '
            "setField<$dartType>('$columnName', value);");
    }
    buffer.writeln(); // Single newline between field pairs
  }

  buffer
    ..writeln('}')
    ..writeln();
  await file.writeAsString(buffer.toString());
}

Future<void> _generateSchemaFiles(
  Map<String, List<Map<String, dynamic>>> tables,
) async {
  final enumsDir = Directory('$root/enums');
  await enumsDir.create(recursive: true);

  // Generate enums file
  await _generateEnumsFile(tables, enumsDir);

  print('[GenerateTypes] Successfully generated enums');
}

Future<void> _generateEnumsFile(
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
  print('[GenerateTypes] Fetching enum types from database...');

  try {
    // Query to get all enum types and their values
    print('[GenerateTypes] Executing RPC call to get_enum_types...');
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

    /// Function to convert [word] to TitleCase
    String toTitleCase(String word) =>
        word[0].toUpperCase() + word.substring(1).toLowerCase();

    // Generate each enum
    print('\n[GenerateTypes] Generating enum definitions:');
    enums.forEach((enumName, values) {
      // Format enum name to PascalCase and remove Enum suffix
      final formattedEnumName = enumName
          .split('_')
          .map(toTitleCase)
          .join()
          .replaceAll(RegExp(r'Enum$'), '');

      print('  Processing: $enumName -> $formattedEnumName');
      formattedEnums[enumName] = formattedEnumName;

      buffer.writeln('enum $formattedEnumName {');
      for (final value in values) {
        buffer.writeln('  $value,');
      }
      buffer.writeln('}');
    });

    await enumFile.writeAsString(buffer.toString());
    print('[GenerateTypes] Generated enums file successfully');
  } catch (e, stackTrace) {
    print('[GenerateTypes] Error generating enums: $e');
    print('[GenerateTypes] Stack trace: $stackTrace');
    rethrow;
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
      baseType = _getBaseDartType(udtName.substring(1), column: column);
    } else if (column['element_type'] != null) {
      baseType = _getBaseDartType(
        column['element_type'] as String,
        column: column,
      );
    } else {
      baseType = _getBaseDartType(
        postgresType.replaceAll('[]', ''),
        column: column,
      );
    }
    return 'List<$baseType>';
  }

  // Non-array types
  return _getBaseDartType(postgresType, column: column);
}

String _getBaseDartType(String postgresType, {Map<String, dynamic>? column}) {
  switch (postgresType.toLowerCase()) {
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
      return (column != null ? formattedEnums[column['udt_name']] : null) ??
          'String'; // For enums

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
