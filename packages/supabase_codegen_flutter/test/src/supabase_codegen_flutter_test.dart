import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

void main() {
  group('SupabaseCodegenFlutter', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('when client not setup throws an assertion error', () async {
      // Assert
      expect(
        () => supabase,
        throwsA(
          isA<AssertionError>().having(
            (e) => e.toString(),
            'message',
            contains('You must initialize'),
          ),
        ),
      );
    });

    test('when client setup has a supabase instance', () async {
      final mockClient = MockSupabaseCodegenFlutterClient();
      await mockClient.loadMockSupabaseClient();

      // Assert
      expect(supabase, isNotNull);
      expect(supabaseClient, Supabase.instance.client);

      // Clean up created instance
      if (mockClient.supabaseInitialized) {
        await Supabase.instance.dispose();
      }
    });
  });
}
