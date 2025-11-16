import 'package:supabase_codegen/src/generator/generator.dart';

/// Schema tables
typedef SchemaTables =
    Map<
      /// Table name
      String,

      /// Columns
      List<Map<String, dynamic>>
    >;

/// Generate the [TableConfig] using the provided [overrides]
Future<List<TableConfig>> generateTableConfigs({
  Map<String, Map<String, ColumnOverride>>? overrides,
  SchemaTables? tables,
}) async {
  final schemaTables = tables ?? await getSchemaTables();
  final tableConfigs = <TableConfig>[];

  // Generate each table config
  for (final entry in schemaTables.entries) {
    final tableName = entry.key;
    final columnSchema = entry.value;
    final tableOverrides = overrides?[tableName];

    // Generate a map of the field name to data for that field
    final fieldNameTypeMap = createFieldNameTypeMap(
      columnSchema,
      tableOverrides: tableOverrides,
    );
    logger
      ..detail('Table Name: $tableName')
      ..detail('Field Name Type Map: $fieldNameTypeMap');

    final tableConfig = TableConfig(
      name: tableName,
      columns: fieldNameTypeMap.sortedEntries
          .map(
            (entry) => ColumnConfig.fromColumnData(
              fieldName: entry.key,
              columnData: entry.value,
            ),
          )
          .toList(),
    );
    tableConfigs.add(tableConfig);
  }
  logger.detail('Table Config Created');
  return tableConfigs;
}

/// Get the schema tables
Future<SchemaTables> getSchemaTables() async {
  // Get table information from Supabase
  final progress = logger.progress('Fetching tables from database...');
  final response = await client.rpc<List<dynamic>>('get_schema_info');

  // Modified to handle direct List response
  final schemaData = List<Map<String, dynamic>>.from(response);

  if (schemaData.isEmpty) {
    const message = 'Failed to fetch schema tables: Empty response';
    progress.fail(message);
    throw Exception(message);
  }

  // Group columns by table
  final tables = <String, List<Map<String, dynamic>>>{};
  for (final column in schemaData) {
    final tableName = column['table_name'] as String;

    if (!tableName.startsWith('_')) {
      tables[tableName] = [...tables[tableName] ?? [], column];
    }
  }

  // After fetching schema info
  logger
    ..detail('Table Count: ${tables.keys.length}')
    ..detail('\nAvailable tables:');
  for (final tableName in tables.keys) {
    logger.detail('  - $tableName');
  }

  logger.detail('Table Map: $tables');

  progress.complete('Database tables fetched');
  return tables;
}
