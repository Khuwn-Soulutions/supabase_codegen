import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import '../../bin/init_functions/env.dart';

void main() {
  group('env.dart', () {
    group('validateEnvFile', () {
      test('returns true for valid env file', () {
        final file = File('test.env')
          ..writeAsStringSync(
            'SUPABASE_URL=https://example.com\nSUPABASE_ANON_KEY=abc123',
          );
        expect(validateEnvFile('test.env'), isTrue);
        file.deleteSync();
      });

      test('returns false for invalid env file', () {
        final file = File('test.env')
          ..writeAsStringSync(
            'SUPABASE_URL=https://example.com\nINVALID_KEY=abc123',
          );
        expect(validateEnvFile('test.env'), isFalse);
        file.deleteSync();
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
      const testEnv = 'env.test';
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
        final result =
            await addEnvFileToAssets(testEnv, pubspecPath: pubspecPath);
        expect(result, isTrue);
        checkPubSpecContents();
      });

      test('adds env file to pubspec.yaml with flutter but no assets',
          () async {
        File(pubspecPath).writeAsStringSync('''
name: test

# Flutter section
flutter:
''');
        final result =
            await addEnvFileToAssets(testEnv, pubspecPath: pubspecPath);
        expect(result, isTrue);
        checkPubSpecContents();
      });

      test('does not add if env file already present in assets', () async {
        File(pubspecPath).writeAsStringSync('''
name: test

flutter:
  assets:
    - $testEnv
''');
        final result =
            await addEnvFileToAssets(testEnv, pubspecPath: pubspecPath);
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
        final result =
            await addEnvFileToAssets(testEnv, pubspecPath: pubspecPath);
        expect(result, isTrue);
        checkPubSpecContents();
        expect(pubspecFile.readAsStringSync(), contains(somethingElse));
      });
    });

    // configureEnv is highly interactive and would require extensive mocking of dcli.ask/confirm/echo.
    // For brevity, not included here.
  });
}
