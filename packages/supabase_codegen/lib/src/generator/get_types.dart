import 'package:supabase_codegen/src/generator/generator.dart';

/// Get the dart type for the provided [column]
String getDartType(Map<String, dynamic> column) {
  final postgresType = (column['data_type'] as String).toLowerCase();
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
      baseType = getBaseDartType(udtName.substring(1), column: column);
    } else if (column['element_type'] != null) {
      baseType = getBaseDartType(
        column['element_type'] as String,
        column: column,
      );
    } else {
      baseType = getBaseDartType(
        postgresType.replaceAll('[]', ''),
        column: column,
      );
    }
    return 'List<$baseType>';
  }

  // Non-array types
  return getBaseDartType(
    postgresType == 'user-defined' ? postgresType : udtName,
    column: column,
  );
}

/// Get the base dart type for the [postgresType]
/// considering the provided [column] data
String getBaseDartType(String postgresType, {Map<String, dynamic>? column}) {
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
      return 'int';

    /// Big integer
    case 'bigint':
      return 'BigInt';

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
      return 'dynamic';

    /// Enum
    case 'user-defined':
      return (column != null ? formattedEnums[column['udt_name']] : null) ??
          'String'; // For enums

    /// Default
    default:
      return 'String';
  }
}

/// Helper to extract generic type from a List
String getGenericType(String listType) {
  final match = RegExp('List<(.+)>').firstMatch(listType);
  return match?.group(1) ?? 'dynamic';
}
