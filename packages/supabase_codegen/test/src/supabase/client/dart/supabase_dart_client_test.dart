import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/src/supabase/client/dart/supabase_dart_client.dart';
import 'package:supabase_codegen/src/supabase/client/supabase_client.mock.dart';
import 'package:test/test.dart';

void main() {
  group('Supabase (Dart) Client', () {
    final envPath = path.join(Directory.current.path, 'test', '.env');
    late SupabaseCodegenClient codegenClient;

    setUp(() {
      codegenClient = SupabaseCodegenClient();
    });

    tearDown(() {
      final envFile = File(envPath);
      if (envFile.existsSync()) {
        envFile.deleteSync();
      }
    });

    /// Write the [contents] to the env file
    void writeEnvFile({
      String url = 'https://example.com',
      String key = '1234567',
    }) {
      final contents = '''
${url.isEmpty ? '' : 'SUPABASE_URL=$url'}
${key.isEmpty ? '' : 'SUPABASE_KEY=$key'}
''';
      File(envPath).writeAsStringSync(contents);
    }

    test('loadSupabaseClient returns a SupabaseClient', () {
      writeEnvFile();
      final client = codegenClient.loadSupabaseClient(envPath);
      expect(client, isA<SupabaseClient>());
    });

    test('loadSupabaseClient caches the client', () {
      writeEnvFile();
      final client1 = codegenClient.loadSupabaseClient(envPath);
      final client2 = codegenClient.loadSupabaseClient(envPath);
      expect(client1, equals(client2));
    });

    test('loadMockSupabaseClient returns mockSupabase', () {
      final client = codegenClient.loadMockSupabaseClient();
      expect(client, equals(mockSupabase));
    });

    test('loadClient returns a SupabaseClient', () async {
      writeEnvFile();

      // Call the function under test
      final client = await codegenClient.loadClientFromEnv(envPath);

      // Expect a valid client
      expect(client, isA<SupabaseClient>());
    });

    group('loadClientFromEnv throws an exception when', () {
      test('required values are missing', () {
        writeEnvFile(url: '', key: '');

        // Call the function under test
        expect(() => codegenClient.loadClientFromEnv(envPath), throwsException);
      });

      test('when no key is provided', () {
        writeEnvFile(key: '');

        // Call the function under test
        expect(
          () => codegenClient.loadClientFromEnv(envPath),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Ensure that either'),
            ),
          ),
        );
      });
    });

    test('setClient sets the supabaseClient', () {
      codegenClient.setClient(SupabaseClient('supabaseUrl', 'supabaseKey'));
      // Expect a valid client
      expect(codegenClient.supabaseClient, isA<SupabaseClient>());
    });

    test('createClient creates client with the url and key provided', () async {
      final url = Uri.parse('https://example.com');
      const key = '09876543234567';
      await codegenClient.createClient(url.toString(), key);
      // Expect a valid client
      expect(codegenClient.supabaseClient, isA<SupabaseClient>());
      expect(
        codegenClient.supabaseClient!.auth.headers['Authorization'],
        contains(key),
      );
      expect(
        codegenClient.supabaseClient!.realtime.endPoint,
        contains(url.host),
      );
    });
  });
}
