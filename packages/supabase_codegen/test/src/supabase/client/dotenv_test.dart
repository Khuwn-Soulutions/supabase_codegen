import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:supabase_codegen/src/supabase/client/dotenv_extension.dart';
import 'package:supabase_codegen/src/supabase/client/supabase_env_keys.dart';
import 'package:test/test.dart';

void main() {
  const supabaseUrl = 'https://id.supabase.co';
  const supabaseKey = 'anon_key';
  const envPath = '.env.test';

  group('DotenvExtension', () {
    late DotEnv dotenv;
    setUp(() {
      dotenv = DotEnv();
    });

    tearDown(() {
      if (File(envPath).existsSync()) {
        File(envPath).deleteSync();
      }
      dotenv.clear();
    });

    group('extractKeys', () {
      test('returns supabase URL and key from env file', () {
        // Create a temporary .env file for testing
        File(envPath).writeAsStringSync(
          '${supabaseEnvKeys.url}=$supabaseUrl\n'
          '${supabaseEnvKeys.anonKey}=$supabaseKey',
        );

        final result = dotenv.extractKeys(envPath);

        expect(result.supabaseUrl, supabaseUrl);
        expect(result.supabaseKey, supabaseKey);
      });

      test(
          'returns supabase URL and key from env file '
          'when anon key is not defined but key is', () {
        // Create a temporary .env file for testing
        File(envPath).writeAsStringSync(
          '${supabaseEnvKeys.url}=$supabaseUrl\n'
          '${supabaseEnvKeys.key}=$supabaseKey',
        );

        final result = dotenv.extractKeys(envPath);

        expect(result.supabaseUrl, supabaseUrl);
        expect(result.supabaseKey, supabaseKey);
      });

      test(
          'returns supabase URL and key from env file when '
          'anon key is not defined but key alias is', () {
        // Create a temporary .env file for testing
        File(envPath).writeAsStringSync(
          '${supabaseEnvKeys.url}=$supabaseUrl\n'
          '${supabaseEnvKeys.key}=$supabaseKey',
        );

        final result = dotenv.extractKeys(envPath);

        expect(result.supabaseUrl, supabaseUrl);
        expect(result.supabaseKey, supabaseKey);
      });

      test(
          'throws exception when supabase URL is missing in env file '
          'and platform env', () {
        // Create a temporary .env file for testing
        File(envPath)
            .writeAsStringSync('${supabaseEnvKeys.anonKey}=$supabaseKey');

        expect(
          () => dotenv.extractKeys(envPath),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Missing ${supabaseEnvKeys.url} in $envPath file.'),
            ),
          ),
        );
      });

      test(
          'throws exception when supabase key is missing in env file and platform env',
          () {
        // Create a temporary .env file for testing
        File(envPath).writeAsStringSync('${supabaseEnvKeys.url}=$supabaseUrl');

        expect(
          () => dotenv.extractKeys(envPath),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains(
                '[GenerateTypes] Ensure that either ${supabaseEnvKeys.anonKey} or '
                '${supabaseEnvKeys.anonKey} is set to ensure access to the database',
              ),
            ),
          ),
        );
      });
    });

    group('extractFromPlatformEnv', () {
      final env = <String, String>{};

      setUp(() {
        env
          ..[supabaseEnvKeys.url] = supabaseUrl
          ..[supabaseEnvKeys.anonKey] = supabaseKey;
      });

      tearDown(() {
        env
          ..remove(supabaseEnvKeys.url)
          ..remove(supabaseEnvKeys.anonKey);
      });

      test('returns supabase URL and key from platform env', () {
        final result = dotenv.extractFromPlatformEnv(env);

        expect(result, isNotNull);
        expect(result!.supabaseUrl, supabaseUrl);
        expect(result.supabaseKey, supabaseKey);
      });

      test(
          'returns supabase URL and key from platform env when anon key is not defined but key is',
          () {
        env.remove(supabaseEnvKeys.anonKey);
        env[supabaseEnvKeys.key] = supabaseKey;

        final result = dotenv.extractFromPlatformEnv(env);

        expect(result, isNotNull);
        expect(result!.supabaseUrl, supabaseUrl);
        expect(result.supabaseKey, supabaseKey);

        env.remove(supabaseEnvKeys.key);
        env[supabaseEnvKeys.anonKey] = supabaseKey;
      });

      test(
          'returns supabase URL and key from platform env when anon key is not defined but key alias is',
          () {
        env.remove(supabaseEnvKeys.anonKey);
        env[supabaseEnvKeys.key] = supabaseKey;

        final result = dotenv.extractFromPlatformEnv(env);

        expect(result, isNotNull);
        expect(result!.supabaseUrl, supabaseUrl);
        expect(result.supabaseKey, supabaseKey);

        env.remove(supabaseEnvKeys.key);
        env[supabaseEnvKeys.anonKey] = supabaseKey;
      });

      test('returns null when supabase URL is missing in platform env', () {
        env.remove(supabaseEnvKeys.url);

        final result = dotenv.extractFromPlatformEnv(env);

        expect(result, isNull);
      });

      test('returns null when supabase key is missing in platform env', () {
        env.remove(supabaseEnvKeys.anonKey);

        final result = dotenv.extractFromPlatformEnv(env);

        expect(result, isNull);
      });
    });
  });
}
