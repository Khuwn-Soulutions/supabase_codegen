import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

void main() {
  final columns = [
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
  ];

  group('createFieldNameTypeMap', () {
    setUpAll(createVerboseLogger);

    test('should return an empty map when given an empty list', () {
      final columns = <Map<String, dynamic>>[];
      final result = createFieldNameTypeMap(columns);
      expect(result, isEmpty);
    });

    test('should correctly map columns to ColumnData', () {
      final result = createFieldNameTypeMap(columns);

      expect(result.length, equals(4));

      const idField = 'id';
      expect(result[idField]?.dartType, equals('int'));
      expect(result[idField]?.isNullable, isFalse);
      expect(result[idField]?.hasDefault, isFalse);
      expect(result[idField]?.columnName, equals('id'));
      expect(result[idField]?.isArray, isFalse);

      const nameField = 'name';
      expect(result[nameField]?.dartType, equals('String'));
      expect(result[nameField]?.isNullable, isTrue);
      expect(result[nameField]?.hasDefault, isTrue);
      expect(result[nameField]?.columnName, equals('name'));
      expect(result[nameField]?.isArray, isFalse);

      const createdAtField = 'createdAt';
      expect(result[createdAtField]?.dartType, equals('DateTime'));
      expect(result[createdAtField]?.isNullable, isFalse);
      expect(result[createdAtField]?.hasDefault, isTrue);
      expect(result[createdAtField]?.columnName, equals('created_at'));
      expect(result[createdAtField]?.isArray, isFalse);

      const tagsField = 'tags';
      expect(result[tagsField]?.dartType, equals('List<String>'));
      expect(result[tagsField]?.isNullable, isTrue);
      expect(result[tagsField]?.hasDefault, isFalse);
      expect(result[tagsField]?.columnName, equals('tags'));
      expect(result[tagsField]?.isArray, isTrue);
    });

    test('should correctly map enum columns to ColumnData', () {
      // Assuming you have a formattedEnums entry for 'my_values'
      formattedEnums['my_values'] = 'MyValues';
      final columns = [
        {
          'column_name': 'enum_field',
          'data_type': 'user-defined',
          'udt_name': 'my_values',
          'is_nullable': 'YES',
          'column_default': null,
        },
      ];

      final result = createFieldNameTypeMap(columns);

      expect(result.length, equals(1));
      const enumField = 'enumField';
      expect(result[enumField]?.dartType, equals('MyValues'));
      expect(result[enumField]?.isNullable, isTrue);
      expect(result[enumField]?.hasDefault, isFalse);
      expect(result[enumField]?.columnName, equals('enum_field'));
      expect(result[enumField]?.isArray, isFalse);
      expect(result[enumField]?.isEnum, isTrue);

      //Clean up for other test
      formattedEnums.remove('my_values');
    });

    test('should correctly map camel case column names', () {
      final columns = [
        {
          'column_name': 'column_with_underscores',
          'data_type': 'text',
          'udt_name': 'text',
          'is_nullable': 'NO',
          'column_default': null,
        },
      ];

      final result = createFieldNameTypeMap(columns);

      const columnField = 'columnWithUnderscores';
      expect(result.containsKey(columnField), isTrue);
      expect(result[columnField]?.dartType, equals('String'));
      expect(result[columnField]?.isNullable, isFalse);
      expect(result[columnField]?.hasDefault, isFalse);
      expect(
        result[columnField]?.columnName,
        equals('column_with_underscores'),
      );
      expect(result[columnField]?.isArray, isFalse);
    });

    test('should set isEnum to false when column is not an enum', () {
      final columns = [
        {
          'column_name': 'not_an_enum',
          'data_type': 'text',
          'udt_name': 'text',
          'is_nullable': 'YES',
          'column_default': null,
        },
      ];

      final result = createFieldNameTypeMap(columns);

      expect(result['notAnEnum']?.isEnum, isFalse);
    });

    test('given tableOverrides then applies overrides', () {
      final tableOverrides = {'name': const ColumnOverride(isNullable: true)};
      final result = createFieldNameTypeMap(
        columns,
        tableOverrides: tableOverrides,
      );

      expect(result['name']?.isNullable, isTrue);
    });
  });

  group('sortedEntries', () {
    final optionalColumn = {
      'column_name': 'optional',
      'data_type': 'text',
      'udt_name': 'text',
      'is_nullable': 'YES',
      'column_default': null,
    };

    final requiredColumn = {
      'column_name': 'required',
      'data_type': 'text',
      'udt_name': 'text',
      'is_nullable': 'NO',
      'column_default': null,
    };
    test('given no entries then returns empty list', () {
      final unsorted = createFieldNameTypeMap(<Map<String, dynamic>>[]);
      final sorted = unsorted.sortedEntries;

      expect(sorted, isEmpty);
    });

    test('given an optional entry followed by a required entry '
        'then required entry is first', () {
      final unsorted = createFieldNameTypeMap([optionalColumn, requiredColumn]);
      final sorted = unsorted.sortedEntries;

      expect(sorted[0].key, equals(requiredColumn['column_name']));
      expect(sorted[1].key, equals(optionalColumn['column_name']));
    });

    test('given an required entry followed by a optional entry '
        'then required order is unchanged', () {
      final unsorted = createFieldNameTypeMap([requiredColumn, optionalColumn]);
      final sorted = unsorted.sortedEntries;

      expect(sorted[0].key, equals(requiredColumn['column_name']));
      expect(sorted[1].key, equals(optionalColumn['column_name']));
    });

    test('given unsorted entries then sorts entries', () {
      final unsorted = createFieldNameTypeMap(columns);
      final sorted = unsorted.sortedEntries;

      expect(sorted.length, equals(unsorted.length));
      expect(sorted[0].key, equals('id'));
      expect(sorted[1].key, equals('name'));
      expect(sorted[2].key, equals('createdAt'));
      expect(sorted[3].key, equals('tags'));
    });
  });
}
