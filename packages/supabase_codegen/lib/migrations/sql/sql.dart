import 'package:supabase_codegen/migrations/sql/get_enum_types.dart';
import 'package:supabase_codegen/migrations/sql/get_rpc_functions.dart';
import 'package:supabase_codegen/migrations/sql/get_schema_info.dart';

export 'get_enum_types.dart';
export 'get_rpc_functions.dart';
export 'get_schema_info.dart';

/// List of sql functions
final sqlFunctions = [getEnumTypes, getRpcFunctions, getSchemaInfo];
