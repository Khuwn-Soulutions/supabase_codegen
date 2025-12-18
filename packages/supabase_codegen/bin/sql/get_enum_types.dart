import 'codegen_sql_function.dart';

final _fn = 'public.${CodegenSqlFunction.getEnumTypes.name}';

/// Function to get enum types
final getEnumTypes =
    '''
CREATE OR REPLACE FUNCTION $_fn()
'''
    r'''
RETURNS TABLE (
    enum_name text,
    enum_value text
)
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.typname::text as enum_name,
        e.enumlabel::text as enum_value
    FROM 
        pg_type t
        JOIN pg_enum e ON t.oid = e.enumtypid
        JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    WHERE 
        n.nspname = 'public'
    ORDER BY 
        t.typname,
        e.enumsortorder;
END;
$$;
'''
    '''

--- Revoke access to the function
REVOKE EXECUTE ON FUNCTION $_fn FROM public, anon, authenticated;

-- Grant access to the function
GRANT EXECUTE ON FUNCTION $_fn TO service_role;
''';
