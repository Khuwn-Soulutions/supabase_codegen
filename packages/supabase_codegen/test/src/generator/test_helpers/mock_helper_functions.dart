/// Creates an enum schema list
List<Map<String, String>> createEnumSchema(
  String enumName,
  List<String> values,
) {
  return values
      .map((value) => {'enum_name': enumName, 'enum_value': value})
      .toList();
}

/// Create table schema list
List<Map<String, String?>> createTableSchema(
  String tableName,
  List<Map<String, String?>> columns,
) {
  return columns.map((column) => {'table_name': tableName, ...column}).toList();
}
