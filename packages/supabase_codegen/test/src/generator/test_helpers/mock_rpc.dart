import 'package:supabase_codegen/supabase_codegen.dart';

const enumRpc = 'get_enum_types';

/// Mock the [enumRpc] function
void mockEnumRpc(List<Map<String, String>> enumData) {
  mockSupabaseHttpClient.registerRpcFunction(
    enumRpc,
    (params, tables) => enumData,
  );
}

const schemaRpc = 'get_schema_info';

/// Mock the [schemaRpc] function
void mockSchemaRpc(List<Map<String, String?>> schemaData) {
  mockSupabaseHttpClient.registerRpcFunction(
    schemaRpc,
    (params, tables) => schemaData,
  );
}
