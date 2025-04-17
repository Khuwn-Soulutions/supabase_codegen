import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

import 'package:supabase_codegen_example/supabase_codegen_example.dart';
import 'package:supabase_codegen_example/types/tables/users.dart';

void main() {
  group('Users Master Screen ', () {
    setUpAll(() {
      loadMockSupabaseClient();
    });

    testWidgets('displays all users', (WidgetTester tester) async {
      await UsersTable().insertRow(
        UsersRow(email: 'me@example.com', accName: 'John Doe'),
      );
      // Build the screen
      await tester.pumpWidget(MaterialApp(home: const UsersMasterScreen()));
      await tester.pumpAndSettle();

      // Verify that user name and email are displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('me@example.com'), findsOneWidget);
    });
  });
}
