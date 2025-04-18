import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Supabase (Flutter) Client', () {
    final envPath = path.join(Directory.current.path, 'test', 'config.env');
    late MockSupabaseCodegenFlutterClient mockClient;
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
      mockClient = MockSupabaseCodegenFlutterClient();
    });

    tearDown(() async {
      final envFile = File(envPath);
      if (envFile.existsSync()) {
        envFile.deleteSync();
      }

      // clear the root bundle cache that is used to cache the file contents
      rootBundle.clear();

      if (mockClient.supabaseInitialized) {
        await Supabase.instance.dispose();
      }
    });

    /// Write the [contents] to the env file
    void writeEnvFile({
      String url = 'https://example.com',
      String key = '1234567',
    }) {
      final contents = '''
SUPABASE_URL=$url
SUPABASE_KEY=$key
''';
      File(envPath).writeAsStringSync(contents);
    }

    group('loadSupabaseClient ', () {
      test(
        'throws an error if client not previously loaded',
        () async {
          expect(mockClient.supabaseClient, isNull);
          expect(
            mockClient.loadSupabaseClient,
            throwsA(
              isA<AssertionError>().having(
                (e) => e.toString(),
                'message',
                contains('You must call'),
              ),
            ),
          );
        },
      );

      test(
        'returns a SupabaseClient after client loaded',
        () async {
          writeEnvFile();
          await mockClient.loadClientFromEnv(envPath);
          final client = mockClient.loadSupabaseClient();
          expect(client, isA<SupabaseClient>());
        },
      );

      test('caches the client', () async {
        writeEnvFile();
        await mockClient.loadClientFromEnv(envPath);
        final client1 = mockClient.loadSupabaseClient(envPath);
        final client2 = mockClient.loadSupabaseClient(envPath);
        expect(client1, equals(client2));
      });
    });

    test('setClient sets the supabaseClient', () {
      mockClient.setClient(SupabaseClient('supabaseUrl', 'supabaseKey'));
      expect(mockClient.supabaseClient, isA<SupabaseClient>());
    });

    test('loadMockSupabaseClient returns mockSupabase', () async {
      final client = await mockClient.loadMockSupabaseClient();
      expect(client, equals(mockSupabase));
      // ensure pause for unawaited future in loadMockSupabaseClient to complete
      await Future<void>.delayed(Duration.zero);
    });

    group('loadClientFromEnv', () {
      test('returns a SupabaseClient', () async {
        writeEnvFile();

        // Call the function under test
        final client = await mockClient.loadClientFromEnv(envPath);

        // Expect a valid client
        expect(client, isA<SupabaseClient>());
        expect(
          Supabase.instance.client,
          equals(mockClient.supabaseClient),
        );
      });

      test('throws an Error when file is empty', () {
        File(envPath).writeAsStringSync('');

        // Call the function under test
        expect(
          () => mockClient.loadClientFromEnv(envPath),
          throwsA(isA<EmptyEnvFileError>()),
        );
      });

      test('throws an exception when required values are missing', () {
        writeEnvFile(url: '', key: '');

        // Call the function under test
        expect(
          () => mockClient.loadClientFromEnv(envPath),
          throwsA(isA<Exception>()),
        );
      });

      test('when no key is provided', () {
        writeEnvFile(key: '');

        // Call the function under test
        expect(
          () => mockClient.loadClientFromEnv(envPath),
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

    test('createClient creates client with the url and key provided', () async {
      final url = Uri.parse('https://example.com');
      const key = '09876543234567';
      await mockClient.createClient(url.toString(), key);
      // Expect a valid client
      expect(mockClient.supabaseClient, isA<SupabaseClient>());
      expect(
        mockClient.supabaseClient!.auth.headers['Authorization'],
        contains(key),
      );
      expect(
        mockClient.supabaseClient!.realtime.endPoint,
        contains(url.host),
      );
    });
  });
}
