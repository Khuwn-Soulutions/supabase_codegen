/// Codegen Sql function
enum CodegenSqlFunction {
  /// Function to get RPC functions
  getRpcFunctions(name: 'get_rpc_functions'),

  /// Function to get enum types
  getEnumTypes(name: 'get_enum_types'),

  /// Function to get schema info
  getSchemaInfo(name: 'get_schema_info');

  const CodegenSqlFunction({required this.name});

  /// Name of the RPC function
  final String name;
}
