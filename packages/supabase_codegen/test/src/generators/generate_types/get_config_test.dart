import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

// Mocking classes and functions
class MockFile extends Mock implements File {}

void main() {
  group('get_config', () {
    late MockFile mockPubspecFile;
    late MockFile mockConfigFile;

    setUp(() {
      mockPubspecFile = MockFile();
      mockConfigFile = MockFile();
    });

    tearDown(() {
      reset(mockPubspecFile);
      reset(mockConfigFile);
    });

    group('extractCodegenConfig', () {
      test('returns the whole config if key is empty', () {
        // Arrange
        const configContent = '''
          env: .configenv
          output: config/output
          tag: configtag
          debug: false
        ''';
        when(() => mockConfigFile.readAsStringSync()).thenReturn(configContent);
        when(() => mockConfigFile.existsSync()).thenReturn(true);

        // Act
        final result = extractCodegenConfig(mockConfigFile);

        // Assert
        expect(result['env'], '.configenv');
        expect(result['output'], 'config/output');
        expect(result['tag'], 'configtag');
        expect(result['debug'], false);
      });

      test('returns empty config if key is not found', () {
        // Arrange
        const configContent = '''
          env: .configenv
          output: config/output
          tag: configtag
          debug: false
        ''';
        when(() => mockConfigFile.readAsStringSync()).thenReturn(configContent);
        when(() => mockConfigFile.existsSync()).thenReturn(true);

        // Act
        final result = extractCodegenConfig(mockConfigFile, key: 'not_found');

        // Assert
        expect(result, isEmpty);
      });

      test('returns the correct config if key is found', () {
        // Arrange
        const configContent = '''
          my_config:
            env: .configenv
            output: config/output
            tag: configtag
            debug: false
        ''';
        when(() => mockConfigFile.readAsStringSync()).thenReturn(configContent);
        when(() => mockConfigFile.existsSync()).thenReturn(true);

        // Act
        final result = extractCodegenConfig(mockConfigFile, key: 'my_config');

        // Assert
        expect(result['env'], '.configenv');
        expect(result['output'], 'config/output');
        expect(result['tag'], 'configtag');
        expect(result['debug'], false);
      });
    });

    group('getPubspecConfig', () {
      test('returns correct config', () {
        // Arrange
        const pubspecContent = '''
        name: test_package
        supabase_codegen:
          env: .testenv
          output: test/output
          tag: testtag
          debug: true
      ''';

        // Mock File.readAsStringSync
        when(
          () => mockPubspecFile.readAsStringSync(),
        ).thenReturn(pubspecContent);
        when(() => mockPubspecFile.existsSync()).thenReturn(true);

        // Act
        final result = getPubspecConfig(file: mockPubspecFile);

        // Assert
        expect(result['env'], '.testenv');
        expect(result['output'], 'test/output');
        expect(result['tag'], 'testtag');
        expect(result['debug'], true);
      });

      test('returns empty config if no supabase_codegen key', () {
        // Arrange
        const pubspecContent = '''
        name: test_package
      ''';
        // Mock File.readAsStringSync
        when(
          () => mockPubspecFile.readAsStringSync(),
        ).thenReturn(pubspecContent);
        when(() => mockPubspecFile.existsSync()).thenReturn(true);

        // Act
        final result = getPubspecConfig(file: mockPubspecFile);

        // Assert
        expect(result, isEmpty);
      });

      test('uses default pubspec.yaml if no file is provided', () {
        // Act
        final result = getPubspecConfig(key: '');

        // Assert
        expect(result['name'], 'supabase_codegen');
      });

      test('returns empty map if file does not exist', () {
        // Arrange
        when(() => mockPubspecFile.existsSync()).thenReturn(false);
        when(() => mockPubspecFile.readAsStringSync()).thenReturn('');

        // Act
        final result = getPubspecConfig(file: mockPubspecFile);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getCodegenConfig', () {
      test('returns config from config file if it exists', () {
        // Arrange
        const configContent = '''
          env: .configenv
          output: config/output
          tag: configtag
          debug: false
        ''';
        when(() => mockConfigFile.readAsStringSync()).thenReturn(configContent);
        when(() => mockConfigFile.existsSync()).thenReturn(true);
        when(() => mockPubspecFile.existsSync()).thenReturn(false);

        // Act
        final result = getCodegenConfig(
          configFile: mockConfigFile,
          pubspecFile: mockPubspecFile,
        );

        // Assert
        expect(result['env'], '.configenv');
        expect(result['output'], 'config/output');
        expect(result['tag'], 'configtag');
        expect(result['debug'], false);
        verifyNever(() => mockPubspecFile.existsSync());
      });

      test('returns config from pubspec if config file does not exist', () {
        // Arrange
        const pubspecContent = '''
        name: test_package
        supabase_codegen:
          env: .pubspecenv
          output: pubspec/output
          tag: pubspectag
          debug: true
        ''';
        when(() => mockConfigFile.existsSync()).thenReturn(false);
        when(
          () => mockPubspecFile.readAsStringSync(),
        ).thenReturn(pubspecContent);
        when(() => mockPubspecFile.existsSync()).thenReturn(true);

        // Act
        final result = getCodegenConfig(
          configFile: mockConfigFile,
          pubspecFile: mockPubspecFile,
        );

        // Assert
        expect(result['env'], '.pubspecenv');
        expect(result['output'], 'pubspec/output');
        expect(result['tag'], 'pubspectag');
        expect(result['debug'], true);
      });
    });
  });
}
