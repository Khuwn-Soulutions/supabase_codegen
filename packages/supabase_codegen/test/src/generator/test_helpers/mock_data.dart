// Enums
const enumOneName = 'enum_one';
const enumOneValues = ['value1', 'value2'];
const enumTwoName = 'enum_two';
const enumTwoValues = ['valueA', 'valueB'];
final testEnumOne = enumOneValues
    .map((value) => {'enum_name': enumOneName, 'enum_value': value})
    .toList();
final testEnumTwo = enumTwoValues
    .map((value) => {'enum_name': enumTwoName, 'enum_value': value})
    .toList();

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
final testTableSchema = testTable.columns
    .map((column) => {'table_name': testTable.name, ...column})
    .toList();
