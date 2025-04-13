import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

import 'expected/expected.dart';

void main() {
  logger = testLogger;

  group('getDefaultValue should return correct default values', () {
    test('when no default value is provided', () {
      expect(getDefaultValue('int'), '0');
      expect(getDefaultValue('double'), '0.0');
      expect(getDefaultValue('bool'), 'false');
      expect(getDefaultValue('String'), "''");
      expect(getDefaultValue('DateTime'), 'DateTime.now()');
      expect(getDefaultValue('List<String>'), 'const <String>[]');
      expect(getDefaultValue('UserStatus'), 'null');
    });

    test('when default value is provided', () {
      final expected = {
        'int': [(defaultValue: "'1'::smallint", value: '1')],
        'double': [(defaultValue: "'0.1'::real", value: '0.1')],
        'bool': [(defaultValue: 'true', value: 'true')],
        'String': [
          (defaultValue: "'N/A'::text", value: "'N/A'"),
          (defaultValue: "''::text", value: "''"),
          (defaultValue: 'gen_random_uuid()', value: "''"),
        ],
        'DateTime': [
          (
            defaultValue: "'2001-01-01 00:00:00+00'::timestamp with time zone",
            value: "DateTime.parse('2001-01-01 00:00:00+00')"
          ),
          (
            defaultValue: "(now() AT TIME ZONE 'utc'::text)",
            value: 'DateTime.now()'
          ),
          (defaultValue: "(now()'::text)", value: 'DateTime.now()'),
          (defaultValue: 'CURRENT_TIMESTAMP', value: 'DateTime.now()'),
        ],
        'Map<String, dynamic>': [
          (defaultValue: "'{}'::jsonb", value: '{}'),
          (defaultValue: "'{\"test\": 1}'::jsonb", value: "{'test': 1}"),
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

  group('writeCopyWith', () {
    test('should generate correct copyWith method', () {
      final buffer = StringBuffer();
      writeCopyWith(
        buffer: buffer,
        entries: testFieldNameTypeMapEntries,
        rowClass: expectedRowClassName,
      );
      expect(buffer.toString(), expectedCopyWith);
    });
  });

  group('writeFields', () {
    test('should generate correct getters and setters', () {
      final buffer = StringBuffer();
      writeFields(
        fieldNameTypeMap: testFieldNameTypeMap,
        buffer: buffer,
        tableClass: expectedTableClassName,
      );
      expect(buffer.toString(), expectedRowFields);
    });

    test('should generate correct getters and setters with enum', () {
      final buffer = StringBuffer();
      final fieldNameTypeMap = <String, ColumnData>{
        'status': (
          dartType: 'UserStatus',
          isNullable: false,
          hasDefault: false,
          defaultValue: null,
          columnName: 'status',
          isArray: false,
          isEnum: true,
        ),
      };
      writeFields(
        fieldNameTypeMap: fieldNameTypeMap,
        buffer: buffer,
        tableClass: 'UserTable',
      );
      const expected = '''
  /// Get the Json representation of the row
  Map<String, dynamic> toJson() => data;

  /// Get the [SupabaseTable] for this row
  @override
  SupabaseTable get table => UserTable();

  /// Status field name
  static const String statusField = 'status';

  /// Status
  UserStatus get status => getField<UserStatus>(statusField, enumValues: UserStatus.values)!;
  set status(UserStatus value) => setField<UserStatus>(statusField, value);

''';
      expect(buffer.toString(), expected);
    });
  });

  group('writeRowClass', () {
    test('should generate correct row class with required and optional fields',
        () {
      final buffer = StringBuffer();
      writeRowClass(
        entries: testFieldNameTypeMapEntries,
        buffer: buffer,
        className: expectedClassName,
        classDesc: expectedClassDesc,
        rowClass: expectedRowClassName,
        fieldNameTypeMap: testFieldNameTypeMap,
        tableClass: expectedTableClassName,
      );
      expect(buffer.toString(), expectedRowClass);
    });

    test('should generate correct row class with array fields', () {
      final buffer = StringBuffer();
      final fieldNameTypeMap = <String, ColumnData>{
        'tags': (
          dartType: 'List<String>',
          isNullable: false,
          hasDefault: false,
          defaultValue: null,
          columnName: 'tags',
          isArray: true,
          isEnum: false,
        ),
      };
      writeRowClass(
        entries: fieldNameTypeMap.entries.toList(),
        buffer: buffer,
        className: 'Item',
        classDesc: 'Item',
        rowClass: 'ItemRow',
        fieldNameTypeMap: fieldNameTypeMap,
        tableClass: 'ItemTable',
      );

      const expected = '''
/// Item Row
class ItemRow extends SupabaseDataRow {
  /// Item Row
  ItemRow({
    required List<String> tags,
  }): super({
    'tags': supaSerialize(tags),
  });

  /// Item Row
  const ItemRow._(super.data);

  /// Create Item Row from a [data] map
  factory ItemRow.fromJson(Map<String, dynamic> data) => ItemRow._(data.cleaned);
  /// Get the Json representation of the row
  Map<String, dynamic> toJson() => data;

  /// Get the [SupabaseTable] for this row
  @override
  SupabaseTable get table => ItemTable();

  /// Tags field name
  static const String tagsField = 'tags';

  /// Tags
  List<String> get tags => getListField<String>(tagsField);
  set tags(List<String>? value) => setListField<String>(tagsField, value);

  /// Make a copy of the current [ItemRow] 
  /// overriding the provided fields
  ItemRow copyWith({
    List<String>? tags,
  }) =>
    ItemRow.fromJson({
      'tags': supaSerialize(tags) ?? data['tags'],
    });
}

''';
      expect(buffer.toString(), expected);
    });
  });

  group('writeTableClass', () {
    test('should generate correct table class', () {
      final buffer = StringBuffer();
      writeTableClass(
        buffer: buffer,
        tableName: 'users',
        classDesc: 'User',
        tableClass: 'UserTable',
        rowClass: 'UserRow',
      );

      const expected = '''
/// User Table
class UserTable extends SupabaseTable<UserRow> {
  /// Table Name
  @override
  String get tableName => 'users';

    /// Create a [UserRow] from the [data] provided
  @override
  UserRow createRow(Map<String, dynamic> data) =>
      UserRow.fromJson(data);
}

''';
      expect(buffer.toString(), expected);
    });
  });
}
