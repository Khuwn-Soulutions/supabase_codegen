import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../bin/src/src.dart';

// Mocking classes and functions
class MockSupabaseCodeGenerator extends Mock implements SupabaseCodeGenerator {}

class MockFile extends Mock implements File {}

void main() {
  group('runGenerateTypes', () {
    late MockSupabaseCodeGenerator mockGenerator;
    late MockFile mockPubspecFile;
    final configFile = File(defaultValues['config-yaml']! as String);

    setUp(() {
      mockGenerator = MockSupabaseCodeGenerator();
      mockPubspecFile = MockFile();

      if (configFile.existsSync()) {
        /// Remove config file
        configFile.deleteSync();
      }

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

      if (configFile.existsSync()) {
        /// Remove config file
        configFile.deleteSync();
      }
    });

    group('it calls generateSupabaseTypes with', () {
      test('correct defaults', () async {
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

      group('correct parameters from', () {
        test('command line', () async {
          // Arrange
          final args = [
            '--env',
            '.testenv',
            '--output',
            'test/output',
            '--tag',
            'testtag',
            '--debug',
            '--skip-footer',
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

        test('default config file if found', () async {
          // Arrange
          final args = <String>[];

          // Mock File.readAsStringSync
          when(() => mockPubspecFile.readAsStringSync()).thenReturn('');
          when(() => mockPubspecFile.existsSync()).thenReturn(true);

          const envFilePath = '.env';
          const outputFolder = '.dart_tool/types';
          const fileTag = 'v1.0.1';
          const skipFooter = true;

          configFile.writeAsStringSync('''
            env: $envFilePath
            output: $outputFolder
            tag: $fileTag
            skipFooter: $skipFooter
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
              envFilePath: envFilePath,
              outputFolder: outputFolder,
              fileTag: fileTag,
              skipFooter: skipFooter,
            ),
          ).called(1);
          verifyNever(() => mockPubspecFile.readAsStringSync());
        });

        test('pubspec if no config file found and has correct key', () async {
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
          when(() => mockPubspecFile.existsSync()).thenReturn(true);

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
      });
    });

    test('it returns usage and exits when --help is provided', () async {
      // Arrange
      final args = ['--help'];

      // Act (outside test we would expect this to be printed)
      final usage = await runGenerateTypes(args, generator: mockGenerator);

      expect(usage, isNotNull);
      for (final entry in defaultValues.entries) {
        expect(usage, contains(entry.key));
        expect(usage, contains(entry.value));
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

    test('it catches error if generateSupabaseTypes throws an exception',
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
  });
}
