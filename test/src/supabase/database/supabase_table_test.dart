import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';
import '../mocks/mocks.dart';

void main() {
  loadMockSupabaseClient();
  final user = UsersRow.fromJson(userData);
  final table = UsersTable();
  const otherEmail = 'other@others.com';
  final otherData = {
    ...userData,
    'email': otherEmail,
  };

  /// Insert data
  Future<void> insertData([Map<String, dynamic>? data]) async {
    await mockSupabase.from(table.tableName).insert(data ?? userData);
  }

  /// Find the user in the database
  Future<UsersRow?> fetchUser() => table.querySingleRow(
        queryFn: (q) => q.eq(UsersRow.idField, user.id),
      );

  group('SupabaseTable', () {
    /// Reset the mock data after each test
    tearDown(mockSupabaseHttpClient.reset);

    /// Close the client at the end of all tests
    tearDownAll(mockSupabaseHttpClient.close);

    group('querySingleRow', () {
      test('returns single row', () async {
        await insertData();
        final result = await fetchUser();
        expect(result, isNotNull);
        expect(result!.id, user.id);
      });

      test('returns null if no data in table', () async {
        final result = await fetchUser();
        expect(result, isNull);
      });
    });

    group('queryRows', () {
      late List<UsersRow> result;
      setUp(() async {
        await insertData();
        await insertData({
          'id': 'other-id',
          ...otherData,
        });
      });

      test('returns a list of rows', () async {
        result = await table.queryRows(
          queryFn: (q) => q.eq(UsersRow.roleField, user.role.name),
        );
        expect(result.length, 2);
      });

      test('returns all rows when no queryFn is provided', () async {
        result = await table.queryRows();
        expect(result.length, 2);
      });

      test('can be limited', () async {
        result = await table.queryRows(
          queryFn: (q) => q.eq(UsersRow.roleField, user.role.name),
          limit: 1,
        );
        expect(result.length, 1);
      });
    });

    group('can insert row', () {
      dynamic result;

      void testResult() {
        expect(result, isNotNull);
        expect(result, isA<UsersRow>());
        expect((result as UsersRow).data, userData);
      }

      setUp(() {
        result = null;
      });
      test('using insertRow with SupabaseDataRow class', () async {
        result = await table.insertRow(user);
        testResult();
      });

      test('using insert with data', () async {
        result = await table.insert(userData);
        testResult();
      });
    });

    group('can upsert row', () {
      setUp(insertData);

      test('updates data in table', () async {
        final other = await table.upsert(otherData);
        for (final key in user.data.keys) {
          /// Fields changed
          if (key == 'email') {
            expect(other.data[key], isNot(user.data[key]));
            expect(other.data[key], otherEmail);
          }

          /// Unchanged fields
          else {
            expect(other.data.containsKey(key), isTrue);
            expect(other.data[key], user.data[key]);
          }
        }

        final results = await table.queryRows(
          queryFn: (q) => q.eq(UsersRow.idField, user.id),
        );
        expect(results.length, 1);

        final check = results.first;
        for (final key in user.data.keys) {
          if (key == 'email') continue;

          expect(check.data.containsKey(key), isTrue);
          expect(check.data[key], user.data[key]);
        }
      });

      test('inserts data in table', () async {
        const otherId = 'other-id';
        final before = await table.querySingleRow(
          queryFn: (q) => q.eq(UsersRow.idField, otherId),
        );
        expect(before, isNull);
        await table.upsert({
          ...otherData,
          'id': otherId,
        });
        final after = await table.querySingleRow(
          queryFn: (q) => q.eq(UsersRow.idField, otherId),
        );
        expect(after, isNotNull);
      });

      test('updates data in table using upsertRow', () async {
        await table.upsertRow(UsersRow.fromJson(otherData));
        final updated = await table.querySingleRow(
          queryFn: (q) => q.eq(UsersRow.idField, user.id),
        );
        expect(updated, isNotNull);
        expect(updated!.email, isNot(user.email));
      });
    });

    group('after insertion of data', () {
      setUp(insertData);
      test('can get single SupabaseDataRow using querySingleRow', () async {
        /// Query for the inserted data
        final row = await table.querySingleRow(
          queryFn: (q) => q.eq(UsersRow.emailField, user.email),
        );
        expect(row, isA<UsersRow>());
        expect(row, isNotNull);
        expect(row!.data, user.data);
      });

      test('can get List<SupabaseDataRow> using queryRows', () async {
        final rows = await table.queryRows(
          queryFn: (q) => q.eq(UsersRow.roleField, user.role.name),
        );
        expect(rows, isNotEmpty);
        expect(rows.first.data, userData);
      });

      group('can update row', () {
        var result = <UsersRow>[];
        const newEmail = 'me@them.com';
        final newData = {
          ...userData,
          UsersRow.emailField: newEmail,
        };

        void testUpdatedResult() {
          expect(result, isNotEmpty);
          final newUser = result.first;
          expect(newUser.email, isNot(user.email));
          expect(newUser.email, newEmail);
        }

        setUp(result.clear);

        test('and by default does not return updated rows', () async {
          final updateResult = await table.update(
            matchingRows: (q) => q.eq(UsersRow.emailField, user.email),
            data: newData,
          );
          expect(updateResult, isEmpty);
          final updatedUser = await mockSupabase
              .from(table.tableName)
              .select()
              .eq(UsersRow.emailField, newEmail)
              .limit(1)
              .single();
          expect(updatedUser[UsersRow.emailField], newEmail);
        });

        group('with', () {
          test('data', () async {
            result = await table.update(
              matchingRows: (q) => q.eq(UsersRow.emailField, user.email),
              data: newData,
              returnRows: true,
            );
            testUpdatedResult();
          });

          test('SupabaseDataRow', () async {
            result = await table.update(
              matchingRows: (q) => q.eq(UsersRow.emailField, user.email),
              row: UsersRow.fromJson(newData),
              returnRows: true,
            );
            testUpdatedResult();
          });
        });

        test('and throws error if no data or row provided', () async {
          expect(
            table.update(
              matchingRows: (q) => q.eq(UsersRow.emailField, user.email),
            ),
            throwsA(isA<AssertionError>()),
          );
        });
      });
    });

    group('deleteRow', () {
      test('can delete row', () async {
        /// Insert data and check fetch result
        await insertData();
        final result = await fetchUser();
        expect(result, isNotNull);

        /// Remove the data from the database and check that its deleted
        final deleted = await table.delete(
          matchingRows: (q) => q.eq(UsersRow.roleField, user.role.name),
        );
        expect(deleted, isEmpty);
        final postDelete = await fetchUser();
        expect(postDelete, isNull);
      });

      test('and can return deleted row', () async {
        await insertData();
        final deleted = await table.delete(
          matchingRows: (q) => q.eq(UsersRow.roleField, user.role.name),
          returnRows: true,
        );
        expect(deleted.length, 1);
      });
    });
  });
}
