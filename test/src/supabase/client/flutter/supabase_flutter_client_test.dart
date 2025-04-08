import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
// Imported for testing
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen/src/supabase/client/flutter/supabase_flutter_client.dart';
import 'package:supabase_codegen/src/supabase/client/supabase_client.mock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_flutter_mocks.dart';

class MockSupabaseCodegenClient extends SupabaseCodegenClient {
  @override
  Future<void> initSupabase({
    required String url,
    required String key,
    Client? httpClient,
  }) async {
    final accessToken = isRunningInTest ? () async => 'Bearer: $key' : null;
    await Supabase.initialize(
      url: url,
      anonKey: key,
      accessToken: accessToken,
      authOptions: FlutterAuthClientOptions(
        localStorage: MockLocalStorage(),
        pkceAsyncStorage: MockAsyncStorage(),
      ),
      httpClient: httpClient,
    );
    supabaseInitialized = true;
  }
}

void main() {
  group('Supabase (Flutter) Client', () {
    final envPath = path.join(Directory.current.path, 'test', '.env');
    late MockSupabaseCodegenClient codegenClient;
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
      codegenClient = MockSupabaseCodegenClient();
    });

    tearDown(() async {
      final envFile = File(envPath);
      if (envFile.existsSync()) {
        envFile.deleteSync();
      }

      // clear the root bundle cache that is used to cache the file contents
      rootBundle.clear();

      if (codegenClient.supabaseInitialized) {
        await Supabase.instance.dispose();
      }
    });

    /// Write the [contents] to the env file
    void writeEnvFile({
      String url = 'https://example.com',
      String key = '1234567',
    }) {
      final contents = '''
SUPABASE_URL=$url'
SUPABASE_KEY=$key'
''';
      File(envPath).writeAsStringSync(contents);
    }

    group('loadSupabaseClient ', () {
      test(
        'throws an error if client not previously loaded',
        () async {
          expect(codegenClient.supabaseClient, isNull);
          expect(
            codegenClient.loadSupabaseClient,
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

      test('setClient sets the supabaseClient', () {
        codegenClient.setClient(SupabaseClient('supabaseUrl', 'supabaseKey'));
        // Expect a valid client
        expect(codegenClient.supabaseClient, isA<SupabaseClient>());
      });

      test(
        'returns a SupabaseClient after client loaded',
        () async {
          writeEnvFile();
          await codegenClient.loadClient(envPath);
          final client = codegenClient.loadSupabaseClient();
          expect(client, isA<SupabaseClient>());
        },
      );

      test('caches the client', () async {
        writeEnvFile();
        await codegenClient.loadClient(envPath);
        final client1 = codegenClient.loadSupabaseClient(envPath);
        final client2 = codegenClient.loadSupabaseClient(envPath);
        expect(client1, equals(client2));
      });
    });

    test('loadMockSupabaseClient returns mockSupabase', () async {
      final client = codegenClient.loadMockSupabaseClient();
      expect(client, equals(mockSupabase));
      // ensure pause for unawaited future in loadMockSupabaseClient to complete
      await Future<void>.delayed(Duration.zero);
    });

    group('loadClient', () {
      test('returns a SupabaseClient', () async {
        writeEnvFile();

        // Call the function under test
        final client = await codegenClient.loadClient(envPath);

        // Expect a valid client
        expect(client, isA<SupabaseClient>());
      });

      test('throws an Error when file is empty', () {
        File(envPath).writeAsStringSync('');

        // Call the function under test
        expect(
          () => codegenClient.loadClient(envPath),
          throwsA(isA<EmptyEnvFileError>()),
        );
      });

      test('throws an exception when keys are missing', () {
        File(envPath).writeAsStringSync('NOT_USED = value');

        // Call the function under test
        expect(
          () => codegenClient.loadClient(envPath),
          throwsA(isA<Exception>()),
        );
      });
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
