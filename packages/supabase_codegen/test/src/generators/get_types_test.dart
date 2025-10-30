import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

void main() {
  final typeToPostgresTypes = {
    DartType.string: [
      'text',
      'varchar',
      'char',
      'character varying',
      'name',
      'bytea',
      'user-defined',
    ],
    DartType.uuidValue: [
      'uuid',
    ],
    DartType.int: [
      'int2',
      'int4',
      'int8',
      'bigint',
      'integer',
    ],
    DartType.double: [
      'float4',
      'float8',
      'numeric',
      'decimal',
      'double precision',
    ],
    DartType.bool: [
      'bool',
      'boolean',
    ],
    DartType.dateTime: [
      'timestamp',
      'timestamptz',
      'timestamp with time zone',
      'timestamp without time zone',
    ],
    DartType.dynamic: [
      'json',
      'jsonb',
    ],
  };
  group('getDartType', () {
    test('returns correct Dart type for various Postgres types (non-array)',
        () {
      for (final entry in typeToPostgresTypes.entries) {
        final dartType = entry.key;
        for (final postgresType in entry.value) {
          expect(
            getDartType({'data_type': postgresType, 'udt_name': postgresType}),
            equals(dartType),
          );
        }
      }
    });

    test('returns correct Dart type for array types', () {
      expect(
        getDartType({'data_type': 'int4', 'udt_name': '_int4'}),
        equals('List<int>'),
      );
      expect(
        getDartType({'data_type': 'text', 'udt_name': '_text'}),
        equals('List<String>'),
      );
      expect(
        getDartType({'data_type': 'bool', 'udt_name': '_bool'}),
        equals('List<bool>'),
      );
      expect(
        getDartType({
          'data_type': 'user-defined',
          'udt_name': '_some_enum',
          'element_type': 'some_enum',
        }),
        equals('List<String>'),
      );
      expect(
        getDartType({
          'data_type': 'integer[]',
        }),
        equals('List<int>'),
      );
      expect(
        getDartType({'data_type': 'ARRAY', 'element_type': 'text'}),
        equals('List<String>'),
      );
      expect(
        getDartType({'data_type': 'varchar', 'is_array': true}),
        equals('List<String>'),
      );
    });

    test('returns ${DartType.string} for unknown types', () {
      expect(
        getDartType({'data_type': 'unknown_type'}),
        equals(DartType.string),
      );
      expect(
        getDartType({'data_type': 'unknown_array', 'udt_name': '_unknown'}),
        equals('List<${DartType.string}>'),
      );
    });

    test('returns enum name when formattedEnums contains udt_name', () {
      formattedEnums['test_enum'] = 'TestEnum';
      expect(
        getDartType({'data_type': 'user-defined', 'udt_name': 'test_enum'}),
        equals('TestEnum'),
      );
      formattedEnums.clear();
    });
  });

  group('getBaseDartType', () {
    test('returns correct base Dart type for Postgres types', () {
      for (final entry in typeToPostgresTypes.entries) {
        for (final postgresType in entry.value) {
          expect(getBaseDartType(postgresType), equals(entry.key));
        }
      }
    });

    test('returns ${DartType.string} for unknown types', () {
      expect(getBaseDartType('unknown_type'), equals(DartType.string));
    });

    test('returns correct enum name when udt_name is in formattedEnums', () {
      formattedEnums['test_enum'] = 'TestEnum';
      expect(
        getBaseDartType('user-defined', column: {'udt_name': 'test_enum'}),
        equals('TestEnum'),
      );
      formattedEnums.clear();
    });
  });

  group('getGenericType', () {
    test('extracts generic type from List<T>', () {
      expect(getGenericType('List<String>'), equals('String'));
      expect(getGenericType('List<int>'), equals('int'));
      expect(
        getGenericType('List<Map<String, dynamic>>'),
        equals('Map<String, dynamic>'),
      );
      expect(getGenericType('List<DateTime>'), equals('DateTime'));
    });

    test('returns dynamic for non-List<T> types', () {
      expect(getGenericType('String'), equals('dynamic'));
      expect(getGenericType('int'), equals('dynamic'));
      expect(getGenericType('Map<String, dynamic>'), equals('dynamic'));
    });
  });
}
