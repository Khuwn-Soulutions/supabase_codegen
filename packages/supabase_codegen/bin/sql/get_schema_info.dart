import 'codegen_sql_function.dart';

final _fn = 'public.${CodegenSqlFunction.getSchemaInfo.name}';

/// Function to get schema information for all tables in the public schema.
final getSchemaInfo =
    '''
CREATE OR REPLACE FUNCTION $_fn()
'''
    r'''
RETURNS TABLE (
    table_name text,
    column_name text,
    data_type text,
    udt_name text,
    is_nullable text,
    column_default text,
    is_array boolean,
    element_type text
) 
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.table_name::text,
        c.column_name::text,
        c.data_type::text,
        c.udt_name::text,
        c.is_nullable::text,
        c.column_default::text,
        (c.data_type = 'ARRAY') AS is_array,
        e.data_type::text as element_type
    FROM 
        information_schema.columns c
    LEFT JOIN 
        information_schema.element_types e 
    ON 
        ((c.table_catalog, c.table_schema, c.table_name, 'TABLE', c.dtd_identifier)
        = (e.object_catalog, e.object_schema, e.object_name, e.object_type, e.collection_type_identifier))
    WHERE 
        c.table_schema = 'public'
        AND c.table_name NOT LIKE 'pg_%'
        AND c.table_name NOT LIKE '_prisma_%'
    ORDER BY 
        c.table_name, 
        c.ordinal_position;
END;
$$;
'''
    '''

--- Revoke access to the function
REVOKE EXECUTE ON FUNCTION $_fn FROM public, anon, authenticated;

-- Grant access to the function
GRANT EXECUTE ON FUNCTION $_fn TO service_role;
''';
