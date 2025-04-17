import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:supabase_codegen/supabase_codegen.dart' show envKeys;
import 'package:test/test.dart';

class MockGeneratorUtils extends Mock implements SupabaseCodeGeneratorUtils {}

void main() {
  late SupabaseCodeGenerator generator;
  logger = testLogger;
  group('generateSupabaseTypes', () {
    generator = const SupabaseCodeGenerator();
    test('it throws an error when env file not found', () {
      expect(
        generator.generateSupabaseTypes(
          envFilePath: '.no-env',
          outputFolder: '',
        ),
        throwsException,
      );
    });

    group('with env file', () {
      final envPath = path.join(Directory.current.path, 'test', '.env');
      late File envFile;

      setUp(() => envFile = File(envPath));

      tearDown(() {
        if (envFile.existsSync()) {
          envFile.deleteSync();
        }
      });

      test('throws an error if it does not contain ${envKeys.url}', () {
        expect(
          generator.generateSupabaseTypes(
            envFilePath: envFile.path,
            outputFolder: '',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Missing ${envKeys.url}'),
            ),
          ),
        );
      });

      test('throws an error when ${envKeys.anonKey} or ${envKeys.key} not set',
          () async {
        envFile.writeAsStringSync('${envKeys.url}=http://db.com');
        expect(
          generator.generateSupabaseTypes(
            envFilePath: envFile.path,
            outputFolder: '',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Ensure that either ${envKeys.anonKey} '
                  'or ${envKeys.anonKey} is set'),
            ),
          ),
        );
      });

      group(
        'sets client',
        () {
          const url = 'http://db.com';
          const anonKey = 'ANON_KEY';
          const key = 'KEY';
          late MockGeneratorUtils mockUtils;

          setUp(() {
            mockUtils = MockGeneratorUtils();
            generator = SupabaseCodeGenerator(utils: mockUtils);
            when(mockUtils.generateSchema).thenAnswer((_) async {});
            when(() => mockUtils.createClient(any<String>(), any<String>()))
                .thenAnswer(
              (inv) => SupabaseClient(
                inv.positionalArguments[0] as String,
                inv.positionalArguments[1] as String,
              ),
            );
          });

          test('with provided ${envKeys.url} and ${envKeys.anonKey}', () async {
            envFile.writeAsStringSync('''
            ${envKeys.url}=$url
            ${envKeys.anonKey}=$anonKey
          ''');
            await generator.generateSupabaseTypes(
              envFilePath: envFile.path,
              outputFolder: '',
            );
            verify(() => mockUtils.createClient(url, anonKey)).called(1);
          });

          test(
              'with provided ${envKeys.anonKey} if both '
              '${envKeys.anonKey} and ${envKeys.key} provided', () async {
            envFile.writeAsStringSync('''
            ${envKeys.url}=$url
            ${envKeys.anonKey}=$anonKey
            ${envKeys.key}=$key
          ''');
            await generator.generateSupabaseTypes(
              envFilePath: envFile.path,
              outputFolder: '',
            );
            verify(() => mockUtils.createClient(url, anonKey)).called(1);
          });

          test(
              'with provided ${envKeys.key} if ${envKeys.anonKey} not provided',
              () async {
            envFile.writeAsStringSync('''
            ${envKeys.url}=$url
            ${envKeys.key}=$key
          ''');
            await generator.generateSupabaseTypes(
              envFilePath: envFile.path,
              outputFolder: '',
            );
            verify(() => mockUtils.createClient(url, key)).called(1);
          });
        },
      );
    });
  });
}
