import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_codegen_serverpod/src/init/init_serverpod.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group('addExtraClassesToGeneratorConfig', () {
    late MockLogger logger;
    late Directory tempDir;
    late File generatorConfig;

    setUp(() {
      logger = MockLogger();
      tempDir = Directory.systemTemp.createTempSync();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('logs warning if $configPath does not exist', () async {
      await addExtraClassesToGeneratorConfig(
        logger: logger,
        directory: tempDir,
      );

      verify(
        () => logger.warn(
          '⚠️ $configPath not found. Skipping extraClasses update.',
        ),
      ).called(1);
    });

    group('when $configPath exists', () {
      setUp(() {
        generatorConfig = File('${tempDir.path}/$configPath')
          ..createSync(recursive: true);
      });

      test('adds extraClasses if file exists but key is missing', () async {
        generatorConfig.writeAsStringSync('project: my_project\n');

        await addExtraClassesToGeneratorConfig(
          logger: logger,
          directory: tempDir,
        );

        final content = generatorConfig.readAsStringSync();
        expect(content, contains('extraClasses:'));
        expect(content, contains(jsonClassImport));
        verify(() => logger.success(any())).called(1);
      });

      test('appends to extraClasses if key exists', () async {
        const otherPackage =
            'package:other_package/other_class.dart:OtherClass';
        generatorConfig.writeAsStringSync('''
project: my_project
extraClasses:
  - $otherPackage
''');

        await addExtraClassesToGeneratorConfig(
          logger: logger,
          directory: tempDir,
        );

        final content = generatorConfig.readAsStringSync();
        expect(content, contains(otherPackage));
        expect(content, contains(jsonClassImport));
        verify(() => logger.success(any())).called(1);
      });

      test('does not duplicate if class already exists', () async {
        generatorConfig.writeAsStringSync('''
project: my_project
extraClasses:
  - $jsonClassImport
''');

        await addExtraClassesToGeneratorConfig(
          logger: logger,
          directory: tempDir,
        );

        final content = generatorConfig.readAsStringSync();
        final occurrences = jsonClassImport.allMatches(content).length;
        expect(occurrences, 1);
        verify(() => logger.info(any())).called(1);
      });

      test(
        'logs error if an exception occurs during file operations',
        () async {
          // Simulate an error by  putting in content that
          // would cause a YAML parsing error
          generatorConfig.writeAsStringSync(
            'project: adsfadsf: extraClasses:',
          );

          await addExtraClassesToGeneratorConfig(
            logger: logger,
            directory: tempDir,
          );

          verify(() => logger.err(any())).called(1);
          verifyNever(() => logger.success(any()));
        },
      );
    });
  });
}
