import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';

void main() {
  group('Supabase Client', () {
    final envPath = path.join(Directory.current.path, 'test', '.env');

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
      final contents =
          '''
${url.isEmpty ? '' : 'SUPABASE_URL=$url'}
${key.isEmpty ? '' : 'SUPABASE_KEY=$key'}
''';
      File(envPath).writeAsStringSync(contents);
    }

    test('loadSupabaseClient returns a SupabaseClient', () {
      writeEnvFile();
      final client = loadSupabaseClient(envPath);
      expect(client, isA<SupabaseClient>());
    });

    test('loadSupabaseClient caches the client', () {
      writeEnvFile();
      final client1 = loadSupabaseClient(envPath);
      final client2 = loadSupabaseClient(envPath);
      expect(client1, equals(client2));
    });

    test('loadMockSupabaseClient returns mockSupabase', () {
      final client = loadMockSupabaseClient();
      expect(client, equals(mockSupabase));
    });

    test('loadClientFromEnv returns a SupabaseClient', () async {
      writeEnvFile();

      // Call the function under test
      final client = loadClientFromEnv(envPath);

      // Expect a valid client
      expect(client, isA<SupabaseClient>());
    });

    test('setClient sets the supabaseClient', () {
      final client = setClient(SupabaseClient('supabaseUrl', 'supabaseKey'));
      // Expect a valid client
      expect(client, isA<SupabaseClient>());
    });

    test('createClient creates client with the url and key provided', () async {
      final url = Uri.parse('https://example.com');
      const key = '09876543234567';
      final client = createClient(url.toString(), key);
      // Expect a valid client
      expect(client, isA<SupabaseClient>());
      expect(client.auth.headers['Authorization'], contains(key));
      expect(client.realtime.endPoint, contains(url.host));
    });
  });
}
