import 'package:supabase_codegen/src/generator/generator.dart';

/// Get the dart type for the provided [column]
String getDartType(Map<String, dynamic> column) {
  final postgresType = (column['data_type'] as String).toLowerCase();
  final udtName = column['udt_name'] as String? ?? '';

  // Improved array detection
  final isArray =
      udtName.startsWith('_') ||
      postgresType.endsWith('[]') ||
      postgresType.toUpperCase() == 'ARRAY' ||
      column['is_array'] == true;

  // Get array type
  if (isArray) return _getArrayType(udtName, column, postgresType);

  // Non-array types
  return getBaseDartType(
    postgresType == 'user-defined' ? postgresType : udtName,
    column: column,
  );
}

/// Get the array type
String _getArrayType(
  String udtName,
  Map<String, dynamic> column,
  String postgresType,
) {
  String baseType;
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

/// Get the base dart type for the [postgresType]
/// considering the provided [column] data
String getBaseDartType(String postgresType, {Map<String, dynamic>? column}) {
  switch (postgresType) {
    /// String
    case 'text':
    case 'varchar':
    case 'char':
    case 'character varying':
    case 'name':
    case 'bytea':
      return DartType.string;

    case 'uuid':
      return DartType.uuidValue;

    /// Integer
    case 'int2':
    case 'int4':
    case 'int8':
    case 'bigint':
    case 'integer':
      return DartType.int;

    /// Double
    case 'float4':
    case 'float8':
    case 'decimal':
    case 'numeric':
    case 'double precision':
      return DartType.double;

    /// Bool
    case 'bool':
    case 'boolean':
      return DartType.bool;

    /// DateTime
    case 'timestamp':
    case 'timestamptz':
    case 'timestamp with time zone':
    case 'timestamp without time zone':
      return DartType.dateTime;

    /// Map
    case 'json':
    case 'jsonb':
      return DartType.dynamic;

    /// Enum
    case 'user-defined':
      return (column != null ? formattedEnums[column['udt_name']] : null) ??
          DartType.string; // For enums

    /// Default
    default:
      return DartType.string;
  }
}

/// Helper to extract generic type from a List
String getGenericType(String listType) {
  final match = RegExp('List<(.+)>').firstMatch(listType);
  return match?.group(1) ?? 'dynamic';
}
