import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';
import '../mocks/mocks.dart';

void main() {
  loadMockSupabaseClient();

  group('SupabaseDataRow', () {
    late UsersRow user;
    final firstField = userData.keys.first;
    const listField = 'contacts';
    final contacts = userData[listField] as List<String>;
    setUp(() => user = UsersRow.fromJson(userData));

    test('can be created with data', () {
      expect(user, isNotNull);
    });

    group('created with fields', () {
      late UsersRow row;
      setUp(() {
        row = UsersRow(
          role: user.role,
          email: user.email,
        );
      });
      test('has fields set to input', () {
        expect(row, isNotNull);
        expect(row.role, user.role);
        expect(row.email, user.email);
      });

      /// This is important so that submitted data will have
      /// default value (if present) for column set in the database
      test('data map does not have optional fields', () {
        for (final key in userData.keys) {
          if (!requiredUserKeys.contains(key)) {
            expect(row.data.containsKey(key), isFalse);
          }
        }
      });
    });

    group('getField', () {
      test('returns field when found', () {
        final value = user.getField<String>(firstField);
        expect(value, isNotNull);
        expect(value, userData[firstField]);
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

      test('gets Enum from field', () {
        final value = user.getField<UserRole>(
          UsersRow.roleField,
          enumValues: UserRole.values,
        );
        expect(value, isA<Enum>());
      });
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

    group('setField', () {
      test('can update a field in the row data', () {
        final newValue = contacts.first;
        user.setField(firstField, newValue);
        expect(user.data[firstField], newValue);
      });

      test('can update an enum field', () {
        const newValue = UserRole.user;
        user.setField(UsersRow.roleField, newValue);
        expect(user.data[UsersRow.roleField], newValue.name);
      });
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
      final usersRow = UsersRow.fromJson(userData);
      expect(user, usersRow);
      expect(user == usersRow, isTrue);
    });

    test('hashCode returns hash', () {
      expect(user.hashCode, greaterThan(0));
    });

    group('copyWith ', () {
      const someEmail = 'some-email';
      late UsersRow copy;
      setUp(() {
        copy = user.copyWith(
          email: someEmail,
        );
      });

      test('overrides provided fields', () {
        expect(copy == user, isFalse);
        expect(copy.email, someEmail);
        expect(copy.data['email'], someEmail);
      });

      test('preserves other fields', () {
        for (final key in user.data.keys) {
          if (key == 'email') continue;

          expect(copy.data.containsKey(key), isTrue);
          expect(copy.data[key], user.data[key]);
        }
      });

      test('maintains empty fields in data', () async {
        final original = UsersRow(email: 'email', role: UserRole.user);
        expect(original.data.containsKey('id'), false);

        const newEmail = 'newEmail';
        final copy = original.copyWith(
          email: newEmail,
        );
        expect(copy.email, newEmail);
        expect(original.data.keys, copy.data.keys);
        expect(copy.data.containsKey('id'), false);
      });
    });
  });
}
