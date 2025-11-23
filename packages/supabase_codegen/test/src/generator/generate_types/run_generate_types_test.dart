import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

// Mocking classes and functions
class MockSupabaseCodeGenerator extends Mock implements SupabaseCodeGenerator {}

class MockFile extends Mock implements File {}

void main() {
  group('runGenerateTypes', () {
    late MockSupabaseCodeGenerator mockGenerator;
    late MockFile mockPubspecFile;
    final configFile = File(defaultValues['config-yaml']! as String);

    setUpAll(() {
      registerFallbackValue(GeneratorConfigParams.empty());
    });

    setUp(() {
      mockGenerator = MockSupabaseCodeGenerator();
      mockPubspecFile = MockFile();

      if (configFile.existsSync()) {
        /// Remove config file
        configFile.deleteSync();
      }

      when(
        () => mockGenerator.generateSupabaseTypes(
          any(that: isA<GeneratorConfigParams>()),
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
            any(
              that: isA<GeneratorConfigParams>()
                  .having(
                    (param) => param.envFilePath,
                    'envFilePath',
                    defaultValues[CmdOption.env],
                  )
                  .having(
                    (param) => param.outputFolder,
                    'outputFolder',
                    defaultValues[CmdOption.output],
                  ),
            ),
          ),
        ).called(1);
      });

      group('correct parameters from', () {
        test('command line', () async {
          // Arrange
          const envFilePath = '.testenv';
          const output = 'test/output';
          const testTag = 'testtag';
          final args = [
            '--env',
            envFilePath,
            '--output',
            output,
            '--tag',
            testTag,
            '--debug',
          ];

          // Act
          await runGenerateTypes(args, generator: mockGenerator);

          // Assert
          verify(
            () => mockGenerator.generateSupabaseTypes(
              any(
                that: isA<GeneratorConfigParams>()
                    .having(
                      (param) => param.envFilePath,
                      'envFilePath',
                      envFilePath,
                    )
                    .having(
                      (param) => param.outputFolder,
                      'outputFolder',
                      output,
                    )
                    .having((param) => param.tag, 'tag', testTag),
              ),
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

          configFile.writeAsStringSync('''
            env: $envFilePath
            output: $outputFolder
            tag: $fileTag
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
              any(
                that: isA<GeneratorConfigParams>()
                    .having(
                      (param) => param.envFilePath,
                      'envFilePath',
                      envFilePath,
                    )
                    .having(
                      (param) => param.outputFolder,
                      'outputFolder',
                      outputFolder,
                    )
                    .having((param) => param.tag, 'tag', fileTag),
              ),
            ),
          ).called(1);
          verifyNever(() => mockPubspecFile.readAsStringSync());
        });

        test('config file given on command line', () async {
          final customConfigFile = File(
            path.join(Directory.current.path, 'test/custom_config.yaml'),
          );

          // Arrange
          final args = <String>[
            '--${CmdOption.configYaml}',
            customConfigFile.path,
          ];

          // Mock File.readAsStringSync
          when(() => mockPubspecFile.readAsStringSync()).thenReturn('');
          when(() => mockPubspecFile.existsSync()).thenReturn(true);

          const envFilePath = '.env';
          const outputFolder = '.dart_tool/types';
          const fileTag = 'v1.0.1';

          customConfigFile.writeAsStringSync('''
            env: $envFilePath
            output: $outputFolder
            tag: $fileTag
          ''');

          // Act
          await runGenerateTypes(
            args,
            generator: mockGenerator,
            pubspecFile: mockPubspecFile,
          );

          customConfigFile.deleteSync();

          // Assert
          verify(
            () => mockGenerator.generateSupabaseTypes(
              any(
                that: isA<GeneratorConfigParams>()
                    .having(
                      (param) => param.envFilePath,
                      'envFilePath',
                      envFilePath,
                    )
                    .having(
                      (param) => param.outputFolder,
                      'outputFolder',
                      outputFolder,
                    )
                    .having((param) => param.tag, 'tag', fileTag),
              ),
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
              any(
                that: isA<GeneratorConfigParams>()
                    .having(
                      (param) => param.envFilePath,
                      'envFilePath',
                      '.pubspecenv',
                    )
                    .having(
                      (param) => param.outputFolder,
                      'outputFolder',
                      'pubspec/output',
                    )
                    .having((param) => param.tag, 'tag', 'pubspectag'),
              ),
            ),
          ).called(1);
        });
      });

      group('forFlutter', () {
        test('false by default', () async {
          // Act
          await runGenerateTypes([], generator: mockGenerator);

          // Assert
          verify(
            () => mockGenerator.generateSupabaseTypes(
              any(
                that: isA<GeneratorConfigParams>()
                    .having(
                      (param) => param.envFilePath,
                      'envFilePath',
                      defaultValues[CmdOption.env] as String,
                    )
                    .having(
                      (param) => param.outputFolder,
                      'outputFolder',
                      defaultValues[CmdOption.output] as String,
                    )
                    .having((param) => param.forFlutter, 'forFlutter', false),
              ),
            ),
          ).called(1);
        });

        test('true if set to true', () async {
          // Act
          await runGenerateTypes(
            [],
            generator: mockGenerator,
            config: GeneratorConfigParams.empty().copyWith(forFlutter: true),
          );

          // Assert
          verify(
            () => mockGenerator.generateSupabaseTypes(
              any(
                that: isA<GeneratorConfigParams>()
                    .having(
                      (param) => param.envFilePath,
                      'envFilePath',
                      defaultValues[CmdOption.env] as String,
                    )
                    .having(
                      (param) => param.outputFolder,
                      'outputFolder',
                      defaultValues[CmdOption.output] as String,
                    )
                    .having((param) => param.forFlutter, 'forFlutter', true),
              ),
            ),
          ).called(1);
        });
      });

      test('output folder if provided in the config', () async {
        // Arrange
        final args = <String>[];
        const outputFolder = 'test';
        final config = GeneratorConfigParams.empty().copyWith(
          outputFolder: outputFolder,
        );

        // Act
        await runGenerateTypes(args, generator: mockGenerator, config: config);

        // Assert
        verify(
          () => mockGenerator.generateSupabaseTypes(
            any(
              that: isA<GeneratorConfigParams>().having(
                (param) => param.outputFolder,
                'outputFolder',
                outputFolder,
              ),
            ),
          ),
        ).called(1);
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
        expect(usage, contains(entry.value.toString()));
      }

      // Assert
      // Verify that no other code was executed.
      verifyNever(
        () => mockGenerator.generateSupabaseTypes(
          any(that: isA<GeneratorConfigParams>()),
        ),
      );
    });

    test(
      'it catches error if generateSupabaseTypes throws an exception',
      () async {
        // Arrange
        final args = <String>[];
        final exception = Exception('Test exception');

        when(
          () => mockGenerator.generateSupabaseTypes(
            any(that: isA<GeneratorConfigParams>()),
          ),
        ).thenThrow(exception);

        // Act and Assert
        expect(
          runGenerateTypes(args, generator: mockGenerator),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
