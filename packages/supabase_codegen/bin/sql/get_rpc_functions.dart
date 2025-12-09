const getRpcFunctions = r'''
CREATE OR REPLACE FUNCTION get_rpc_functions(include_internals boolean DEFAULT false)
RETURNS TABLE(
  schema_name text,
  function_name text,
  arguments text,
  return_type text
)
LANGUAGE sql
AS $$
SELECT n.nspname AS schema_name,
       p.proname AS function_name,
       pg_get_function_arguments(p.oid) AS arguments,
       pg_get_function_result(p.oid) AS return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('public')
  AND pg_get_function_result(p.oid) <> 'trigger'
  AND (include_internals OR p.proname NOT IN ('get_rpc_functions', 'get_enum_types', 'get_schema_info'))
ORDER BY n.nspname, p.proname;
$$;
''';
