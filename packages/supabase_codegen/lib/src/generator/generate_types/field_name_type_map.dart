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
  List<MapEntry<String, ColumnData>> get sortedEntries => entries.toList()
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
}
