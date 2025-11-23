import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('extractDefaultValue', () {
    final defaultValues = {
      'now()': (
        dartType: 'DateTime',
        expected: 'now',
      ),
      'gen_random_uuid()': (
        dartType: 'UuidValue',
        expected: 'random',
      ),
      'gen_random_uuid_v7()': (
        dartType: 'UuidValue',
        expected: 'random_v7',
      ),
      "nextval('table_id_seq'::regclass)": (
        dartType: 'int',
        expected: 'serial',
      ),
      "'10.5'::double precision": (
        dartType: 'double',
        expected: '10.5',
      ),
      "'10'::bigint": (
        dartType: 'int',
        expected: '10',
      ),
      "'This is a string'::text": (
        dartType: 'String',
        expected: "'This is a string'",
      ),
      'true': (dartType: 'bool', expected: 'true'),
      'false': (dartType: 'bool', expected: 'false'),
      null: (dartType: 'String', expected: ''),
      "(now() AT TIME ZONE 'utc'::text)": (
        dartType: 'DateTime',
        expected: 'now',
      ),
      "'2001-01-01'::date": (
        dartType: 'DateTime',
        expected: '2001-01-01T00:00:00.000',
      ),
      "'2001-01-02 00:00:00+00'::timestamp with time zone": (
        dartType: 'DateTime',
        expected: '2001-01-02T00:00:00.000Z',
      ),
      // Ignored
      "'{a,b}'::text[]": (
        dartType: 'List<String>',
        expected: '',
      ),
      "'{\"test\": 1}'::jsonb": (
        dartType: 'Object',
        expected: '',
      ),
    };

    for (final entry in defaultValues.entries) {
      final defaultValue = entry.key;
      final (:dartType, :expected) = entry.value;

      if (defaultValue == null) continue;

      test('returns the correct default key for $defaultValue', () {
        final value = extractDefaultValue(defaultValue, dartType);
        expect(value, expected);
      });
    }
  });
}
