import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';

void main() {
  group('createFieldNameTypeMap', () {
    logger = testLogger;

    test('should return an empty map when given an empty list', () {
      final columns = <Map<String, dynamic>>[];
      final result = createFieldNameTypeMap(columns);
      expect(result, isEmpty);
    });

    test('should correctly map columns to ColumnData', () {
      final columns = [
        {
          'column_name': 'id',
          'data_type': 'int4',
          'udt_name': 'int4',
          'is_nullable': 'NO',
          'column_default': null,
        },
        {
          'column_name': 'name',
          'data_type': 'text',
          'udt_name': 'text',
          'is_nullable': 'YES',
          'column_default': 'some default',
        },
        {
          'column_name': 'created_at',
          'data_type': 'timestamp',
          'udt_name': 'timestamp',
          'is_nullable': 'NO',
          'column_default': 'now()',
        },
        {
          'column_name': 'tags',
          'data_type': 'ARRAY',
          'udt_name': '_text', // Array type
          'is_nullable': 'YES',
          'column_default': null,
        },
      ];

      final result = createFieldNameTypeMap(columns);

      expect(result.length, equals(4));

      expect(result['id']?.dartType, equals('int'));
      expect(result['id']?.isNullable, isFalse);
      expect(result['id']?.hasDefault, isFalse);
      expect(result['id']?.columnName, equals('id'));
      expect(result['id']?.isArray, isFalse);

      expect(result['name']?.dartType, equals('String'));
      expect(result['name']?.isNullable, isTrue);
      expect(result['name']?.hasDefault, isTrue);
      expect(result['name']?.columnName, equals('name'));
      expect(result['name']?.isArray, isFalse);

      expect(result['createdAt']?.dartType, equals('DateTime'));
      expect(result['createdAt']?.isNullable, isFalse);
      expect(result['createdAt']?.hasDefault, isTrue);
      expect(result['createdAt']?.columnName, equals('created_at'));
      expect(result['createdAt']?.isArray, isFalse);

      expect(result['tags']?.dartType, equals('List<String>'));
      expect(result['tags']?.isNullable, isTrue);
      expect(result['tags']?.hasDefault, isFalse);
      expect(result['tags']?.columnName, equals('tags'));
      expect(result['tags']?.isArray, isTrue);
    });

    test('should correctly map enum columns to ColumnData', () {
      // Assuming you have a formattedEnums entry for 'my_values'
      formattedEnums['my_values'] = 'MyValues';
      final columns = [
        {
          'column_name': 'enum_field',
          'data_type': 'user-defined',
          'udt_name': 'my_values',
          'is_nullable': 'YES',
          'column_default': null,
        },
      ];

      final result = createFieldNameTypeMap(columns);

      expect(result.length, equals(1));
      expect(result['enumField']?.dartType, equals('MyValues'));
      expect(result['enumField']?.isNullable, isTrue);
      expect(result['enumField']?.hasDefault, isFalse);
      expect(result['enumField']?.columnName, equals('enum_field'));
      expect(result['enumField']?.isArray, isFalse);
      expect(result['enumField']?.isEnum, isTrue);

      //Clean up for other test
      formattedEnums.remove('my_values');
    });

    test('should correctly map camel case column names', () {
      final columns = [
        {
          'column_name': 'column_with_underscores',
          'data_type': 'text',
          'udt_name': 'text',
          'is_nullable': 'NO',
          'column_default': null,
        },
      ];

      final result = createFieldNameTypeMap(columns);

      expect(result.containsKey('columnWithUnderscores'), isTrue);
      expect(result['columnWithUnderscores']?.dartType, equals('String'));
      expect(result['columnWithUnderscores']?.isNullable, isFalse);
      expect(result['columnWithUnderscores']?.hasDefault, isFalse);
      expect(
        result['columnWithUnderscores']?.columnName,
        equals('column_with_underscores'),
      );
      expect(result['columnWithUnderscores']?.isArray, isFalse);
    });

    test('should set isEnum to false when column is not an enum', () {
      final columns = [
        {
          'column_name': 'not_an_enum',
          'data_type': 'text',
          'udt_name': 'text',
          'is_nullable': 'YES',
          'column_default': null,
        },
      ];

      final result = createFieldNameTypeMap(columns);

      expect(result['notAnEnum']?.isEnum, isFalse);
    });
  });

  /// Get schema tables
  group('getSchemaTables', () {
    const schemaRpc = 'get_schema_info';

    setUp(() {
      client = mockSupabase;
    });

    /// Get the schema tables for the given [schemaData]
    Future<Map<String, List<Map<String, dynamic>>>> getSchemaTablesFor(
      dynamic schemaData,
    ) async {
      mockSupabaseHttpClient.registerRpcFunction(
        schemaRpc,
        (params, tables) => schemaData,
      );
      return getSchemaTables();
    }

    test('should return a map of tables when response is a List', () async {
      final result = await getSchemaTablesFor([
        {'table_name': 'table1', 'column_name': 'col1'},
        {'table_name': 'table1', 'column_name': 'col2'},
        {'table_name': 'table2', 'column_name': 'col1'},
      ]);

      expect(result.length, equals(2));
      expect(result['table1']?.length, equals(2));
      expect(result['table2']?.length, equals(1));
      expect(result['table1']?[0]['column_name'], equals('col1'));
    });

    test('should return a map of tables when response is a Map with data',
        () async {
      final result = await getSchemaTablesFor({
        'data': [
          {'table_name': 'table1', 'column_name': 'col1'},
          {'table_name': 'table1', 'column_name': 'col2'},
          {'table_name': 'table2', 'column_name': 'col1'},
        ],
      });

      expect(result.length, equals(2));
      expect(result['table1']?.length, equals(2));
      expect(result['table2']?.length, equals(1));
      expect(result['table1']?[0]['column_name'], equals('col1'));
    });

    test('should throw an exception when response is empty', () async {
      expect(getSchemaTablesFor(<dynamic>[]), throwsException);
    });

    test('should filter out tables starting with an underscore', () async {
      final result = await getSchemaTablesFor([
        {'table_name': '_table1', 'column_name': 'col1'},
        {'table_name': 'table2', 'column_name': 'col1'},
      ]);

      expect(result.length, equals(1));
      expect(result.containsKey('_table1'), isFalse);
      expect(result.containsKey('table2'), isTrue);
    });
  });

  /// Generate table barrel files
  group('generateTableBarrelFile', () {
    late Directory testTablesDir;
    late Directory testRootDir;
    const testOutputFolder = 'test/test_output_barrel';
    const testTableName = 'test_table';

    setUp(() {
      client = mockSupabase;
      mockSupabaseHttpClient.reset();
      final rootPath = path.join(Directory.current.path, testOutputFolder);
      testRootDir = Directory(rootPath);
      final dirPath = path.join(rootPath, 'tables');
      testTablesDir = Directory(dirPath);

      // Ensure test output directory exists
      if (!testTablesDir.existsSync()) {
        testTablesDir.createSync(recursive: true);
      }

      // Create a dummy table file for the export
      File('${testTablesDir.path}/$testTableName.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('// Dummy table file');

      // Set the root path
      root = rootPath;
    });

    tearDown(() {
      // Clean up test output
      if (testTablesDir.parent.existsSync()) {
        testTablesDir.parent.deleteSync(recursive: true);
      }
    });

    test('generates table barrel file successfully', () async {
      final tables = {
        testTableName: [
          {
            'column_name': 'id',
            'data_type': 'int4',
            'udt_name': 'int4',
            'is_nullable': 'NO',
            'column_default': null,
          },
          {
            'column_name': 'name',
            'data_type': 'text',
            'udt_name': 'text',
            'is_nullable': 'YES',
            'column_default': null,
          },
        ],
        'table_two': [
          {
            'column_name': 'id',
            'data_type': 'int4',
            'udt_name': 'int4',
            'is_nullable': 'NO',
            'column_default': null,
          },
        ],
      };

      await generateTableBarrelFile(tables, testTablesDir);

      final barrelFile = File('${testTablesDir.path}/$tableBarrelFileName');
      expect(barrelFile.existsSync(), isTrue);
      final barrelFileContent = barrelFile.readAsStringSync();
      expect(barrelFileContent, contains("export '$testTableName.dart';"));
      expect(barrelFileContent, contains("export 'table_two.dart';"));
      expect(barrelFileContent, contains('Generated by supabase_codegen'));
    });

    test('generates database.dart file successfully', () async {
      final tables = {
        testTableName: [
          {
            'column_name': 'id',
            'data_type': 'int4',
            'udt_name': 'int4',
            'is_nullable': 'NO',
            'column_default': null,
          },
          {
            'column_name': 'name',
            'data_type': 'text',
            'udt_name': 'text',
            'is_nullable': 'YES',
            'column_default': null,
          },
        ],
      };
      // Create dummy enums file
      final enumsDir = Directory('${testRootDir.path}/enums')
        ..createSync(recursive: true);

      File('${enumsDir.path}/$enumBarrelFileName.dart')
        ..createSync()
        ..writeAsStringSync('// Dummy enums file');

      await generateTableBarrelFile(tables, testTablesDir);

      final databaseFile = File('${testRootDir.path}/database.dart');
      expect(databaseFile.existsSync(), isTrue);
      final databaseFileContent = databaseFile.readAsStringSync();
      expect(
        databaseFileContent,
        contains("export 'enums/$enumBarrelFileName.dart';"),
      );
      expect(
        databaseFileContent,
        contains("export 'tables/$tableBarrelFileName';"),
      );
      expect(databaseFileContent, contains('Generated by supabase_codegen'));
    });

    test('generates empty table barrel file when no tables', () async {
      final tables = <String, List<Map<String, dynamic>>>{};
      await generateTableBarrelFile(tables, testTablesDir);

      final barrelFile = File('${testTablesDir.path}/$tableBarrelFileName');
      expect(barrelFile.existsSync(), isTrue);
      final barrelFileContent = barrelFile.readAsStringSync();
      expect(barrelFileContent, contains('//'));
      expect(barrelFileContent, contains('Generated file. Do not edit.'));
      expect(barrelFileContent, contains('Generated by supabase_codegen'));
      expect(barrelFileContent.trim(), isNot(endsWith("export '")));
    });
  });
}
