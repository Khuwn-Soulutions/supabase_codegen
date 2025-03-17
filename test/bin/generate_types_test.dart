import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../bin/generate_types.dart';
import '../../bin/src/src.dart';

// Mocking classes and functions
class MockSupabaseCodeGenerator extends Mock implements SupabaseCodeGenerator {}

class MockFile extends Mock implements File {}

void main() {
  group('main', () {
    late MockSupabaseCodeGenerator mockGenerator;
    late MockFile mockPubspecFile;

    setUp(() {
      mockGenerator = MockSupabaseCodeGenerator();
      mockPubspecFile = MockFile();

      when(
        () => mockGenerator.generateSupabaseTypes(
          envFilePath: any(named: 'envFilePath'),
          outputFolder: any(named: 'outputFolder'),
          fileTag: any(named: 'fileTag'),
          skipFooter: any(named: 'skipFooter'),
        ),
      ).thenAnswer((_) async => {});
    });

    tearDown(() {
      reset(mockGenerator);
      reset(mockPubspecFile);
    });

    test('it calls generateSupabaseTypes with correct defaults', () async {
      // Arrange
      final args = <String>[];

      // Act
      await runGenerateTypes(args, generator: mockGenerator);

      // Assert
      verify(
        () => mockGenerator.generateSupabaseTypes(
          envFilePath: '.env',
          outputFolder: 'supabase/types',
        ),
      ).called(1);
    });

    test(
        'it calls generateSupabaseTypes with correct parameters '
        'from command line', () async {
      // Arrange
      final args = [
        '--env',
        '.testenv',
        '--output',
        'test/output',
        '--tag',
        'testtag',
        '--debug',
        '--skipFooter',
      ];

      // Act
      await runGenerateTypes(args, generator: mockGenerator);

      // Assert
      verify(
        () => mockGenerator.generateSupabaseTypes(
          envFilePath: '.testenv',
          outputFolder: 'test/output',
          fileTag: 'testtag',
          skipFooter: true,
        ),
      ).called(1);
    });

    test('it calls generateSupabaseTypes with correct parameters from pubspec',
        () async {
      // Arrange
      final args = <String>[];

      // Mock File.readAsStringSync
      when(() => mockPubspecFile.readAsStringSync()).thenReturn('''
      name: test_package
      supabase_codegen:
        env: .pubspecenv
        output: pubspec/output
        tag: pubspectag
        debug: true
        skipFooter: true
      ''');

      // Act
      await runGenerateTypes(
        args,
        generator: mockGenerator,
        pubspecFile: mockPubspecFile,
      );

      // Assert
      verify(
        () => mockGenerator.generateSupabaseTypes(
          envFilePath: '.pubspecenv',
          outputFolder: 'pubspec/output',
          fileTag: 'pubspectag',
          skipFooter: true,
        ),
      ).called(1);
    });

    test('it returns usage and exits when --help is provided', () async {
      // Arrange
      final args = ['--help'];

      // Act (outside test we would expect this to be printed)
      final usage = await runGenerateTypes(args, generator: mockGenerator);

      expect(usage, isNotNull);
      for (final entry in defaultValues.entries) {
        expect(usage, contains(entry.key));
      }

      // Assert
      // Verify that no other code was executed.
      verifyNever(
        () => mockGenerator.generateSupabaseTypes(
          envFilePath: any(named: 'envFilePath'),
          outputFolder: any(named: 'outputFolder'),
          fileTag: any(named: 'fileTag'),
          skipFooter: any(named: 'skipFooter'),
        ),
      );
    });

    test('it throws error if generateSupabaseTypes throws an exception',
        () async {
      // Arrange
      final args = <String>[];
      final exception = Exception('Test exception');

      when(
        () => mockGenerator.generateSupabaseTypes(
          envFilePath: any(named: 'envFilePath'),
          outputFolder: any(named: 'outputFolder'),
          fileTag: any(named: 'fileTag'),
          skipFooter: any(named: 'skipFooter'),
        ),
      ).thenThrow(exception);

      // Act and Assert
      expect(
        runGenerateTypes(args, generator: mockGenerator),
        throwsA(isA<Exception>()),
      );
    });

    test('getPubspecConfig returns correct config', () {
      // Arrange
      const pubspecContent = '''
        name: test_package
        supabase_codegen:
          env: .testenv
          output: test/output
          tag: testtag
          debug: true
          skipFooter: true
      ''';

      // Mock File.readAsStringSync
      when(() => mockPubspecFile.readAsStringSync()).thenReturn(pubspecContent);

      // Act
      final result = getPubspecConfig(mockPubspecFile);

      // Assert
      expect(result['env'], '.testenv');
      expect(result['output'], 'test/output');
      expect(result['tag'], 'testtag');
      expect(result['debug'], true);
      expect(result['skipFooter'], true);
    });

    test('getPubspecConfig returns empty config if no supabase_codegen key',
        () {
      // Arrange
      const pubspecContent = '''
        name: test_package
      ''';
      // Mock File.readAsStringSync
      when(() => mockPubspecFile.readAsStringSync()).thenReturn(pubspecContent);

      // Act
      final result = getPubspecConfig(mockPubspecFile);

      // Assert
      expect(result, isEmpty);
    });
  });
}
