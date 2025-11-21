import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:supabase_codegen/supabase_codegen.dart' show supabaseEnvKeys;
import 'package:test/test.dart';

class MockSchemaGenerator extends Mock implements SupabaseSchemaGenerator {}

class MockLogger extends Mock implements Logger {}

void main() {
  late SupabaseCodeGenerator generator;
  logger = testLogger;
  late GeneratorConfigParams params;

  setUp(() {
    params = GeneratorConfigParams.empty();
  });

  group('SupabaseCodeGenerator', () {
    generator = const SupabaseCodeGenerator();
    test('it throws an error when env file not found', () {
      expect(
        generator.generateSupabaseTypes(
          params.copyWith(envFilePath: '.no-env'),
        ),
        throwsException,
      );
    });

    group('with env file', () {
      final envPath = path.join(
        Directory.current.path,
        'test',
        '.env-gen-test',
      );
      late File envFile;

      setUp(() {
        envFile = File(envPath);
        params = params.copyWith(envFilePath: envFile.path);
      });

      tearDown(() {
        if (envFile.existsSync()) {
          envFile.deleteSync();
        }
      });

      test('throws an error if it does not contain ${supabaseEnvKeys.url}', () {
        expect(
          generator.generateSupabaseTypes(params),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Missing ${supabaseEnvKeys.url}'),
            ),
          ),
        );
      });

      test('throws an error when ${supabaseEnvKeys.anonKey} or '
          '${supabaseEnvKeys.key} not set', () async {
        envFile.writeAsStringSync('${supabaseEnvKeys.url}=http://db.com');
        expect(
          generator.generateSupabaseTypes(params),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains(
                '${supabaseEnvKeys.key} is required to access the '
                'database schema.',
              ),
            ),
          ),
        );
      });

      group('sets client', () {
        const url = 'http://db.com';
        const anonKey = 'ANON_KEY';
        const key = 'KEY';
        late MockSchemaGenerator mockSchemaGenerator;

        setUp(() {
          mockSchemaGenerator = MockSchemaGenerator();
          generator = SupabaseCodeGenerator(
            schemaGenerator: mockSchemaGenerator,
          );
          when(
            () => mockSchemaGenerator.generateSchema(any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockSchemaGenerator.generate(params),
          ).thenAnswer((_) async => true);
          when(
            () =>
                mockSchemaGenerator.createClient(any<String>(), any<String>()),
          ).thenAnswer(
            (inv) => SupabaseClient(
              inv.positionalArguments[0] as String,
              inv.positionalArguments[1] as String,
            ),
          );
        });

        test(
          'with provided ${supabaseEnvKeys.key} if both '
          '${supabaseEnvKeys.anonKey} and ${supabaseEnvKeys.key} provided',
          () async {
            envFile.writeAsStringSync('''
            ${supabaseEnvKeys.url}=$url
            ${supabaseEnvKeys.anonKey}=$anonKey
            ${supabaseEnvKeys.key}=$key
          ''');
            await generator.generateSupabaseTypes(params);
            verify(() => mockSchemaGenerator.createClient(url, key)).called(1);
          },
        );

        test('with provided ${supabaseEnvKeys.key} if '
            '${supabaseEnvKeys.anonKey} not provided', () async {
          envFile.writeAsStringSync('''
            ${supabaseEnvKeys.url}=$url
            ${supabaseEnvKeys.key}=$key
          ''');
          await generator.generateSupabaseTypes(params);
          verify(() => mockSchemaGenerator.createClient(url, key)).called(1);
        });

        test('and handles failed generation', () async {
          envFile.writeAsStringSync('''
            ${supabaseEnvKeys.url}=$url
            ${supabaseEnvKeys.anonKey}=$anonKey
            ${supabaseEnvKeys.key}=$key
          ''');
          logger = MockLogger();
          when(
            () => logger.progress(any()),
          ).thenAnswer((_) => Logger().progress('message'));
          when(
            () => mockSchemaGenerator.generate(params),
          ).thenAnswer((_) async => false);
          await generator.generateSupabaseTypes(params);
          verify(() => logger.alert(any())).called(1);
        });
      });
    });
  });
}
