import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseCodegenFlutter', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('when client not setup throws an assertion error', () async {
      // Assert
      expect(
        () => SupabaseCodegenFlutter.supabase,
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
      expect(SupabaseCodegenFlutter.supabase, isNotNull);
      expect(SupabaseCodegenFlutter.supabase.client, Supabase.instance.client);

      // Clean up created instance
      if (mockClient.supabaseInitialized) {
        await Supabase.instance.dispose();
      }
    });
  });
}
