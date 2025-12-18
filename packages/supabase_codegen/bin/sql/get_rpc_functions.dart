import 'codegen_sql_function.dart';

final _fn = 'public.${CodegenSqlFunction.getRpcFunctions.name}';

final _codegenFns = CodegenSqlFunction.values
    .map((e) => "'${e.name}'")
    .join(', ');

/// Function to get RPC functions
final getRpcFunctions =
    '''
CREATE OR REPLACE FUNCTION $_fn(include_internals boolean DEFAULT false)
'''
    r'''
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
  AND p.prokind = 'f'
  AND (include_internals OR p.proname NOT IN '''
    '($_codegenFns))'
    r'''

ORDER BY n.nspname, p.proname;
$$;
'''
    '''

--- Revoke access to the function
REVOKE EXECUTE ON FUNCTION $_fn FROM public, anon, authenticated;

-- Grant access to the function
GRANT EXECUTE ON FUNCTION $_fn TO service_role;

''';
