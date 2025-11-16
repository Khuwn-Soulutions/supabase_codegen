import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';

void main() {
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

    test('should return a map of tables', () async {
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

  group('generateTableConfigs', () {
    setUpAll(createVerboseLogger);

    final columns = [
      {
        'column_name': 'name',
        'data_type': 'text',
        'udt_name': 'text',
        'is_nullable': 'YES',
        'column_default': 'some default',
      },
    ];

    const tableName = 'table1';
    final tables = {tableName: columns};

    test('should generate table configs', () async {
      final result = await generateTableConfigs(tables: tables);
      const config = TableConfig(
        name: tableName,
        columns: [
          ColumnConfig(
            dartType: DartType.string,
            isNullable: true,
            hasDefault: true,
            defaultValue: 'some default',
            columnName: 'name',
            isArray: false,
            isEnum: false,
            parameterName: 'name',
            constructor: ColumnConstructorConfig(
              isOptional: true,
              qualifier: '',
              question: '?',
            ),
            field: ColumnFieldConfig(
              name: 'nameField',
              defaultValue: "'some default'",
              genericType: '',
              question: '',
              bang: '!',
            ),
          ),
        ],
      );

      expect(result.length, equals(1));
      expect(result.first, equals(config));
      expect(result[0].name, equals(tableName));
      expect(result[0].columns.length, equals(columns.length));
    });
  });
}
