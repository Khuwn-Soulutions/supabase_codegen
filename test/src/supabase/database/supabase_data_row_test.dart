import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';

final Map<String, dynamic> data = {
  'email': 'john@example.com',
  'acc_name': 'John Doe',
  'phone_number': '+1234567890',
  'contacts': ['me@them.com'],
};

class UsersTable extends SupabaseTable<UsersRow> {
  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  const UsersRow(super.data);

  @override
  SupabaseTable get table => UsersTable();
}

void main() {
  group('SupabaseDataRow', () {
    late UsersRow user;
    final firstField = data.keys.first;
    const listField = 'contacts';
    final contacts = data[listField] as List<String>;
    setUp(() => user = UsersRow(data));

    test('it can be created with data', () {
      expect(user, isNotNull);
    });

    group('getField', () {
      test('returns field when found', () {
        final value = user.getField<String>(firstField);
        expect(value, isNotNull);
        expect(value, data[firstField]);
      });

      test('returns null if field not found', () {
        final value = user.getField<String>('not-found');
        expect(value, isNull);
      });

      test(
        'returns default value if field not found and defaultValue provided',
        () {
          const defaultValue = 'defaultValue';
          final value = user.getField<String>(
            'not-found',
            defaultValue: defaultValue,
          );
          expect(value, isNotNull);
          expect(value, defaultValue);
        },
      );
    });

    group('getListField', () {
      test('returns list field when found', () {
        final value = user.getListField<String>(listField);
        expect(value, isNotNull);
        expect(value, contacts);
      });

      test('returns null if field not found', () {
        final value = user.getField<String>('list-not-found');
        expect(value, isNull);
      });

      test(
        'returns empty list if field not found',
        () {
          final value = user.getListField<String>('list-not-found');
          expect(value, isNotNull);
          expect(value, isEmpty);
        },
      );
    });

    test('setField can update a field in the row data', () {
      final newValue = contacts.first;
      user.setField(firstField, newValue);
      expect(user.data[firstField], newValue);
    });

    test('setListField can udpate a list field in the row data', () {
      user.setListField(listField, contacts);
      expect(user.data[listField], contacts);
    });

    test('toString represents row as string', () {
      final userString = user.toString();
      // Debug output
      // ignore: avoid_print
      print(userString);
      expect(userString, isNotEmpty);
      expect(userString, contains(user.tableName));
      expect(userString, contains(firstField));
    });

    test('== equates rows', () {
      expect(user, UsersRow(data));
    });

    test('hasCode returns hash', () {
      expect(user.hashCode, greaterThan(0));
    });
  });
}
