import 'package:test/test.dart';
import '../mocks/mocks.dart';

void main() {
  group('SupabaseDataRow', () {
    late UsersRow user;
    final firstField = userData.keys.first;
    const listField = 'contacts';
    final contacts = userData[listField] as List<String>;
    setUp(() => user = UsersRow(userData));

    test('can be created with data', () {
      expect(user, isNotNull);
    });

    group('created with fields', () {
      late UsersRow row;
      setUp(() {
        row = UsersRow.withFields(
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
          roleField,
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
        user.setField(roleField, newValue);
        expect(user.data[roleField], newValue.name);
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
      expect(user, UsersRow(userData));
    });

    test('hasCode returns hash', () {
      expect(user.hashCode, greaterThan(0));
    });
  });
}
