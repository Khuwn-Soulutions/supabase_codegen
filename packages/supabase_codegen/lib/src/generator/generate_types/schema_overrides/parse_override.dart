import 'package:supabase_codegen/src/generator/generator.dart';

/// Option key for schema overrides
const configOverrideOption = 'override';

/// Extract the [SchemaOverrides] from the [codegenConfig]
SchemaOverrides extractSchemaOverrides(Map<String, dynamic> codegenConfig) =>
    parseSchemaOverrides(codegenConfig[configOverrideOption]);

/// Parse the [SchemaOverrides] from a [Map]
SchemaOverrides parseSchemaOverrides(dynamic overrides) {
  final schemaOverrides = <String, Map<String, ColumnOverride>>{};
  if (overrides is! Map) return schemaOverrides;

  // Parse each override
  for (final entry in overrides.entries) {
    final tableName = entry.key.toString();
    final columns = entry.value as Map;
    final columnOverrides = <String, ColumnOverride>{};

    // Parse columns
    for (final columnEntry in columns.entries) {
      final columnName = columnEntry.key.toString();
      final columnValue = columnEntry.value;
      if (columnValue is! Map) continue;

      // Parse column value as map
      final columnOverride = ColumnOverride.fromJson(columnValue);
      columnOverrides[columnName] = columnOverride;
    }
    schemaOverrides[tableName] = columnOverrides;
  }
  return schemaOverrides;
}
