import 'package:change_case/change_case.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Column data type
typedef ColumnData = ({
  String dartType,
  bool isNullable,
  bool hasDefault,
  dynamic defaultValue,
  String columnName,
  bool isArray,
  bool isEnum,
});

/// Field name type map
typedef FieldNameTypeMap = Map<String, ColumnData>;

/// [FieldNameTypeMap] extension
extension FieldNameTypeMapExtension on FieldNameTypeMap {
  /// Get the entries sorted with the required listed first
  List<MapEntry<String, ColumnData>> get sortedEntries =>
      entries.toList()..sort((a, b) {
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
}

/// Create a map of the field name to data for that field
FieldNameTypeMap createFieldNameTypeMap(
  List<GetSchemaInfoResponse> columns, {
  TableOverrides? tableOverrides,
}) {
  /// Store a map of the column name to type
  final fieldNameTypeMap = <String, ColumnData>{};
  for (final column in columns) {
    final columnName = column.columnName;
    final columnOverride = tableOverrides?[columnName];
    final fieldName = columnName.toCamelCase();
    final dartType = columnOverride?.dataType ?? getDartType(column);
    final isNullable = columnOverride?.isNullable ?? column.isNullable.isYes;
    final isArray = dartType.startsWith('List<');
    final defaultValue =
        columnOverride?.columnDefault ??
        column.raw[GetSchemaInfoResponse.columnDefaultField];
    final hasDefault = defaultValue != null;
    final isEnum = formattedEnums[column.udtName] != null;

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
      ..detail('[GenerateTableFile] Processing column: $columnName')
      ..detail('  Column data: $columnData');
  }
  return fieldNameTypeMap;
}
