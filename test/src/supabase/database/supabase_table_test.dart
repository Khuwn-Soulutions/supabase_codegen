import 'package:test/test.dart';
import '../mocks/mocks.dart';

void main() {
  final user = UsersRow(userData);
  final table = UsersTable();

  /// Insert data
  Future<void> insertData() async {
    await mockSupabase.from(table.tableName).insert(userData);
  }

  group('SupabaseTable', () {
    /// Reset the mock data after each test
    tearDown(mockSupabaseHttpClient.reset);

    /// Close the client at the end of all tests
    tearDownAll(mockSupabaseHttpClient.close);

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

    group('after insertion of data', () {
      setUp(insertData);
      test('can get single SupabaseDataRow using querySingleRow', () async {
        /// Query for the inserted data
        final row = await table.querySingleRow(
          queryFn: (q) => q.eq(emailField, user.email),
        );
        expect(row, isA<UsersRow>());
        expect(row, isNotNull);
        expect(row!.data, user.data);
      });

      test('can get List<SupabaseDataRow> using queryRows', () async {
        final rows = await table.queryRows(
          queryFn: (q) => q.eq(roleField, user.role.name),
        );
        expect(rows, isNotEmpty);
        expect(rows.first.data, userData);
      });

      group('can update row', () {
        var result = <UsersRow>[];
        const newEmail = 'me@them.com';
        final newData = {
          ...userData,
          emailField: newEmail,
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
            matchingRows: (q) => q.eq(emailField, user.email),
            data: newData,
          );
          expect(updateResult, isEmpty);
          final updatedUser = await mockSupabase
              .from(table.tableName)
              .select()
              .eq(emailField, newEmail)
              .limit(1)
              .single();
          expect(updatedUser[emailField], newEmail);
        });

        group('with', () {
          test('data', () async {
            result = await table.update(
              matchingRows: (q) => q.eq(emailField, user.email),
              data: newData,
              returnRows: true,
            );
            testUpdatedResult();
          });

          test('SupabaseDataRow', () async {
            result = await table.update(
              matchingRows: (q) => q.eq(emailField, user.email),
              row: UsersRow(newData),
              returnRows: true,
            );
            testUpdatedResult();
          });
        });

        test('and throws error if no data or row provided', () async {
          expect(
            table.update(
              matchingRows: (q) => q.eq(emailField, user.email),
            ),
            throwsA(isA<AssertionError>()),
          );
        });
      });
    });

    test('can delete row', () async {
      await table.delete(
        matchingRows: (q) => q.eq(roleField, user.role.name),
        returnRows: true,
      );
    });
  });
}
