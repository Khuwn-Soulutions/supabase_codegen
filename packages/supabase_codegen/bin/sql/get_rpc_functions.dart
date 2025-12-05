const getRpcFunctions = r'''
CREATE OR REPLACE FUNCTION get_rpc_functions()
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
ORDER BY n.nspname, p.proname;
$$;
''';
