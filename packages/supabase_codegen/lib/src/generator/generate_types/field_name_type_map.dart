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
