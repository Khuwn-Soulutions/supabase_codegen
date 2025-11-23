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
