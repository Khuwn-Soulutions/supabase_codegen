import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

void main() {
  group('getDefaultValue should return correct default values', () {
    setUpAll(createVerboseLogger);
    test('when no default value is provided', () {
      final expected = {
        DartType.int: '0',
        DartType.double: '0.0',
        DartType.bool: 'false',
        DartType.string: "''",
        DartType.dateTime: 'DateTime.now()',
        DartType.uuidValue: 'const Uuid().v4obj()',
        DartType.dynamic: DartType.nullString,
        'List<String>': 'const <String>[]',
        'UserStatus': 'null',
      };
      for (final type in expected.keys) {
        final value = expected[type]!;
        expect(getDefaultValue(type), value);
      }
    });

    test('when default value is provided', () {
      final expected = {
        'int': [
          (defaultValue: "'1'::smallint", value: '1'),
          (defaultValue: "nextval('tb_id_seq'::regclass)", value: '0'),
        ],
        'double': [(defaultValue: "'0.1'::real", value: '0.1')],
        'bool': [(defaultValue: 'true', value: 'true')],
        'String': [
          (defaultValue: "'N/A'::text", value: "'N/A'"),
          (defaultValue: "''::text", value: "''"),
        ],
        'UuidValue': [
          (defaultValue: 'gen_random_uuid()', value: 'const Uuid().v4obj()'),
        ],
        'DateTime': [
          (
            defaultValue: "'2001-01-01 00:00:00+00'::timestamp with time zone",
            value: "DateTime.parse('2001-01-01 00:00:00+00')",
          ),
          (
            defaultValue: "(now() AT TIME ZONE 'utc'::text)",
            value: 'DateTime.now()',
          ),
          (defaultValue: "(now()'::text)", value: 'DateTime.now()'),
          (defaultValue: 'CURRENT_TIMESTAMP', value: 'DateTime.now()'),
        ],
        'dynamic': [
          (defaultValue: "'{}'::jsonb", value: '{}'),
          (defaultValue: "'{\"test\": 1}'::jsonb", value: "{'test': 1}"),
          (
            defaultValue: "[{\"test\": 1}, {\"test\": 2}]'::jsonb",
            value: "[{'test': 1}, {'test': 2}]",
          ),
          (defaultValue: "'{invalid json}'::jsonb", value: 'null'),
        ],
        'List<String>': [
          (defaultValue: "'{}'::text[]", value: 'const <String>[]'),
          (defaultValue: "'{a,b}'::text[]", value: "const <String>['a', 'b']"),
        ],
        'List<int>': [
          (defaultValue: "'{}'::smallint[]", value: 'const <int>[]'),
          (defaultValue: "'{1,2}'::smallint[]", value: 'const <int>[1, 2]'),
        ],
      };
      for (final type in expected.keys) {
        final values = expected[type]!;
        for (final (:defaultValue, :value) in values) {
          expect(getDefaultValue(type, defaultValue: defaultValue), value);
        }
      }

      expect(
        getDefaultValue(
          'UserStatus',
          defaultValue: "'online'::\"User_Status\"",
          isEnum: true,
        ),
        'UserStatus.online',
      );
    });
  });
}
