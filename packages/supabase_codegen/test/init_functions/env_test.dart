import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_codegen/init/init_functions/env.dart';
import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('env.dart', () {
    group('validateEnvFile', () {
      late File file;
      setUp(() {
        file = File('test.env');
      });

      tearDown(() {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });

      group('returns true for valid env file', () {
        tearDown(() {
          expect(validateEnvFile('test.env'), isTrue);
        });
        test('with url and anon key', () {
          file.writeAsStringSync('''
SUPABASE_URL=https://example.com
SUPABASE_ANON_KEY=abc123
''');
        });

        test('with url and key', () {
          file.writeAsStringSync('''
SUPABASE_URL=https://example.com
SUPABASE_KEY=abc123
''');
        });

        test('with url and key with other variables', () {
          file.writeAsStringSync('''
SUPABASE_URL=https://example.com
# Other variables
FOO=bar

# Supabase key
SUPABASE_KEY=abc123
''');
        });
      });

      test('returns false for invalid env file', () {
        file.writeAsStringSync('''
SUPABASE_URL=https://example.com
INVALID_KEY=abc123
''');
        expect(validateEnvFile('test.env'), isFalse);
      });
    });

    group('createEnvFile', () {
      const dummyEnvPath = 'test/dummy.env';

      tearDown(() {
        final dummyEnvFile = File(dummyEnvPath);
        if (dummyEnvFile.existsSync()) {
          dummyEnvFile.deleteSync();
        }
      });

      test('returns false when user chooses not to create file', () {
        expect(
          createEnvFile(
            dummyEnvPath,
            defaults: (create: false, key: null, url: null),
          ),
          false,
        );
      });

      test('creates env file with key and url provided when confirmed', () {
        const url = 'https://example.com';
        const key = 'abc123';
        expect(
          createEnvFile(
            dummyEnvPath,
            defaults: (create: true, key: key, url: url),
          ),
          isTrue,
        );
        final envContents = File(dummyEnvPath).readAsStringSync();
        expect(envContents, contains('SUPABASE_URL=$url'));
        expect(envContents, contains('SUPABASE_ANON_KEY=$key'));
        expect(validateEnvFile(dummyEnvPath), isTrue);
      });
    });

    group('addEnvFileToAssets', () {
      const testEnv = 'env-dart.test.env';
      const pubspecPath = 'test/test_pubspec.yaml';
      final pubspecFile = File(pubspecPath);

      void checkPubSpecContents() {
        final pubspecContents = pubspecFile.readAsStringSync();
        final pubSpecyaml = loadYaml(pubspecContents) as YamlMap;
        expect(pubSpecyaml.containsKey('flutter'), isTrue);
        expect(pubSpecyaml['flutter'], isNotNull);
        final flutter = pubSpecyaml['flutter'] as YamlMap;
        expect(flutter.containsKey('assets'), isTrue);
        expect(flutter['assets'], isNotNull);
        final assets = flutter['assets'] as YamlList;
        expect(assets.contains(testEnv), isTrue);
      }

      tearDown(() {
        if (pubspecFile.existsSync()) {
          pubspecFile.deleteSync();
        }
      });

      test('adds env file to pubspec.yaml with no flutter section', () async {
        File(pubspecPath).writeAsStringSync('name: test');
        final result = await addEnvFileToAssets(
          testEnv,
          pubspecPath: pubspecPath,
        );
        expect(result, isTrue);
        checkPubSpecContents();
      });

      test(
        'adds env file to pubspec.yaml with flutter but no assets',
        () async {
          File(pubspecPath).writeAsStringSync('''
name: test

# Flutter section
flutter:
''');
          final result = await addEnvFileToAssets(
            testEnv,
            pubspecPath: pubspecPath,
          );
          expect(result, isTrue);
          checkPubSpecContents();
        },
      );

      test(
        'adds env file to pubspec.yaml with flutter in dependencies',
        () async {
          File(pubspecPath).writeAsStringSync('''
name: test

dependencies:
  flutter:
    sdk: flutter

# Flutter section
flutter:
''');
          final result = await addEnvFileToAssets(
            testEnv,
            pubspecPath: pubspecPath,
          );
          expect(result, isTrue);
          checkPubSpecContents();
        },
      );

      test('does not add if env file already present in assets', () async {
        File(pubspecPath).writeAsStringSync('''
name: test

flutter:
  assets:
    - $testEnv
''');
        final result = await addEnvFileToAssets(
          testEnv,
          pubspecPath: pubspecPath,
        );
        expect(result, isFalse);
        checkPubSpecContents();
      });

      test('adds env file to assets if not present', () async {
        const somethingElse = 'something_else';
        File(pubspecPath).writeAsStringSync('''
name: test
flutter:
  assets:
    - $somethingElse
''');
        final result = await addEnvFileToAssets(
          testEnv,
          pubspecPath: pubspecPath,
        );
        expect(result, isTrue);
        checkPubSpecContents();
        expect(pubspecFile.readAsStringSync(), contains(somethingElse));
      });
    });

    group('configureEnv', () {
      final testDir = Directory.systemTemp.createTempSync();
      final envPath = path.join(testDir.path, 'configure_env.env');
      final pubspecPath = path.join(testDir.path, 'test_pubspec.yaml');
      final envFile = File(envPath);
      final pubspecFile = File(pubspecPath);

      tearDown(() async {
        if (envFile.existsSync()) {
          envFile.deleteSync();
        }
        if (pubspecFile.existsSync()) {
          pubspecFile.deleteSync();
        }
      });

      test('It returns the correct env path when the file is valid '
          'and not for flutter', () async {
        envFile.writeAsStringSync('''
SUPABASE_URL=https://example.com
SUPABASE_ANON_KEY=abc123
''');

        final result = await configureEnv(defaultEnvPath: envPath);

        expect(result, envPath);
      });

      test('It returns the correct env path from defaultValues when the file '
          'is valid, not for flutter and no value provided', () async {
        envFile.writeAsStringSync('''
SUPABASE_URL=https://example.com
SUPABASE_ANON_KEY=abc123
''');
        defaultValues[CmdOption.env] = envPath;

        final result = await configureEnv();

        expect(result, envPath);
      });

      test('It returns an error message if the file is invalid', () async {
        envFile.writeAsStringSync('''
INVALID_ENV=nothing
''');

        expect(
          () => configureEnv(defaultEnvPath: envPath),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Env file not valid'),
            ),
          ),
        );
      });

      test('It adds the env file to pubspec.yaml when it is a flutter project '
          'and the user confirms', () async {
        envFile.writeAsStringSync('''
SUPABASE_URL=https://example.com
SUPABASE_ANON_KEY=abc123
''');
        pubspecFile.writeAsStringSync('name: test_pkg');
        final result = await configureEnv(
          defaultEnvPath: envPath,
          forFlutter: true,
          pubspecPath: pubspecPath,
        );

        expect(result, envPath);

        final pubspecContents = pubspecFile.readAsStringSync();
        final pubSpecyaml = loadYaml(pubspecContents) as YamlMap;
        final flutter = pubSpecyaml['flutter'] as YamlMap;
        final assets = flutter['assets'] as YamlList;
        expect(assets.contains(envPath), isTrue);
      });

      test('It does NOT add the env file to pubspec.yaml when it is a flutter '
          'project and the user denies', () async {
        envFile.writeAsStringSync('''
SUPABASE_URL=https://example.com
SUPABASE_ANON_KEY=abc123
''');
        pubspecFile.writeAsStringSync('name: test_pkg');

        final result = await configureEnv(
          defaultEnvPath: envPath,
          forFlutter: true,
          loadFlutterClient: false,
        );

        expect(result, envPath);

        final pubspecContents = pubspecFile.readAsStringSync();
        final pubSpecyaml = loadYaml(pubspecContents) as YamlMap;
        expect(pubSpecyaml.containsKey('flutter'), isFalse);
      });

      test(
        'It creates the env file if it does not exist and the user agrees',
        () async {
          const url = 'https://example.com';
          const key = 'abc123';

          final result = await configureEnv(
            defaultEnvPath: envPath,
            createDefaults: (create: true, url: url, key: key),
          );

          expect(result, envPath);
          expect(envFile.existsSync(), isTrue);

          final envContents = envFile.readAsStringSync();
          expect(envContents, contains('SUPABASE_URL=$url'));
          expect(envContents, contains('SUPABASE_ANON_KEY=$key'));
        },
      );

      test('It does not creates the env file if it '
          'does not exist and the user disagrees', () async {
        const url = 'https://example.com';
        const key = 'abc123';

        expect(
          () => configureEnv(
            defaultEnvPath: envPath,
            createDefaults: (create: false, url: url, key: key),
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Env file not created'),
            ),
          ),
        );
      });
    });
  });
}
