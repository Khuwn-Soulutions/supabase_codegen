// Enums
import 'mock_helper_functions.dart';

const enumOneName = 'enum_one';
const enumOneValues = ['value1', 'value2'];
const enumTwoName = 'enum_two';
const enumTwoValues = ['valueA', 'valueB'];
final testEnumOne = createEnumSchema(enumOneName, enumOneValues);
final testEnumTwo = createEnumSchema(enumTwoName, enumTwoValues);

// Tables
final testTable = (
  name: 'table1',
  columns: [
    {
      'column_name': 'name',
      'data_type': 'text',
      'udt_name': 'text',
      'is_nullable': 'YES',
      'column_default': 'some default',
    },
    {
      'column_name': 'created_at',
      'data_type': 'timestamp',
      'udt_name': 'timestamp',
      'is_nullable': 'NO',
      'column_default': 'now()',
    },
    {
      'column_name': 'tags',
      'data_type': 'ARRAY',
      'udt_name': '_text', // Array type
      'is_nullable': 'YES',
      'column_default': null,
    },
    {
      'column_name': 'id',
      'data_type': 'int4',
      'udt_name': 'int4',
      'is_nullable': 'NO',
      'column_default': null,
    },
  ],
);
final testTableSchema = createTableSchema(testTable.name, testTable.columns);

final testRpcJson = {
  'schema_name': 'public',
  'function_name': 'test_function',
  'arguments': 'arg1 integer, arg2 text',
  'return_type': 'text',
};

final testRpcFunctionsData = [
  {
    'schema_name': 'public',
    'function_name': 'add_numbers',
    'arguments': 'a integer, b integer',
    'return_type': 'integer',
  },
  {
    'schema_name': 'public',
    'function_name': 'concat_texts',
    'arguments': 'parts text[]',
    'return_type': 'text',
  },
  {
    'schema_name': 'public',
    'function_name': 'get_enum_types',
    'arguments': '',
    'return_type': 'TABLE(enum_name text, enum_value text)',
  },
  {
    'schema_name': 'public',
    'function_name': 'get_user_summary',
    'arguments':
        'min_logins integer DEFAULT 0, role_filter text DEFAULT NULL, '
        'limit_count integer DEFAULT 50, offset_count integer DEFAULT 0',
    'return_type':
        'TABLE(email text, login_count integer, roles text[], profile jsonb)',
  },
  {
    'schema_name': 'public',
    'function_name': 'greet_person',
    'arguments': 'payload jsonb',
    'return_type': 'text',
  },
  {
    'schema_name': 'public',
    'function_name': 'list_users',
    'arguments': '',
    'return_type': 'SETOF users',
  },
  {
    'schema_name': 'public',
    'function_name': 'process_payload',
    'arguments': 'payload jsonb',
    'return_type': 'jsonb',
  },
  {
    'schema_name': 'public',
    'function_name': 'reverse_int_array',
    'arguments': 'input_array integer[]',
    'return_type': 'integer[]',
  },
  {
    'schema_name': 'public',
    'function_name': 'store_blob',
    'arguments': 'encoded_base64 text',
    'return_type': 'boolean',
  },
  {
    'schema_name': 'public',
    'function_name': 'sum_array',
    'arguments': 'arr integer[]',
    'return_type': 'integer',
  },
];
