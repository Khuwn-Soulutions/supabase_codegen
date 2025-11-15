import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

// Mocks
class MockLogger extends Mock implements Logger {}

class MockProgress extends Mock implements Progress {}

void main() {
  group('BundleGenerator', () {
    late BundleGenerator bundleGenerator;
    late MockLogger mockLogger;
    late MockProgress mockProgress;
    late Directory tempDir;
    final tables = [
      TableConfig(name: 'users', columns: [ColumnConfig.empty()]),
    ];
    final enums = [
      const EnumConfig(
        formattedEnumName: 'UserStatus',
        enumName: 'User_Status',
        values: ['active', 'inactive'],
      ),
    ];
    final baseConfig = GeneratorConfig.empty().copyWith(
      tables: tables,
      enums: enums,
    );
    late File databaseFile;
    late Directory enumsDir;
    late Directory tablesDir;
    late File tablesBarrelFile;
    late File enumsBarrelFile;

    setUp(() {
      mockLogger = MockLogger();
      mockProgress = MockProgress();
      when(() => mockLogger.progress(any())).thenReturn(mockProgress);
      when(() => mockLogger.detail(any())).thenReturn(null);
      when(() => mockLogger.success(any())).thenReturn(null);
      when(mockProgress.complete).thenReturn(null);
      when(() => mockProgress.update(any())).thenReturn(null);
      logger = mockLogger;

      bundleGenerator = const BundleGenerator();
      tempDir = Directory.systemTemp.createTempSync('bundle_generator_test');
      databaseFile = File(p.join(tempDir.path, 'database.dart'));
      enumsDir = Directory(p.join(tempDir.path, 'enums'));
      tablesDir = Directory(p.join(tempDir.path, 'tables'));
      tablesBarrelFile = File(p.join(tempDir.path, 'tables/_tables.dart'));
      enumsBarrelFile = File(p.join(tempDir.path, 'enums/_enums.dart'));
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
      BundleGenerator.generatedFiles.clear();
    });

    test('generateFiles creates tables, enums, and barrel files '
        'when barrelFiles is true', () async {
      // Arrange
      final config = baseConfig.copyWith(barrelFiles: true);
      final upserts = config.copyWith();

      // Act
      await bundleGenerator.generateFiles(tempDir, upserts, config);

      // Assert

      expect(
        databaseFile.existsSync(),
        isTrue,
        reason: 'database.dart should exist',
      );
      expect(
        enumsDir.existsSync(),
        isTrue,
        reason: 'enums directory should exist',
      );
      expect(
        tablesDir.existsSync(),
        isTrue,
        reason: 'tables directory should exist',
      );
      expect(
        tablesBarrelFile.existsSync(),
        isTrue,
        reason: 'tables barrel file should exist',
      );
      expect(
        enumsBarrelFile.existsSync(),
        isTrue,
        reason: 'enums barrel file should exist',
      );

      verify(
        () => mockLogger.progress('Generating Tables and Enums...'),
      ).called(1);
      verify(() => mockProgress.update('Generating barrel files')).called(1);
      verify(
        () => mockLogger.progress('Cleaning up generated files'),
      ).called(1);
    });

    test(
      'generateFiles creates only tables and enums when barrelFiles is false',
      () async {
        // Arrange
        final config = baseConfig.copyWith(barrelFiles: false);
        final upserts = config.copyWith();

        // Act
        await bundleGenerator.generateFiles(tempDir, upserts, config);

        // Assert

        expect(enumsDir.existsSync(), isTrue);
        expect(tablesDir.existsSync(), isTrue);
        expect(databaseFile.existsSync(), isFalse);
        expect(tablesBarrelFile.existsSync(), isFalse);
        expect(enumsBarrelFile.existsSync(), isFalse);

        verify(
          () => mockLogger.progress('Generating Tables and Enums...'),
        ).called(1);
        verifyNever(() => mockProgress.update('Generating barrel files'));
        verify(
          () => mockLogger.progress('Cleaning up generated files'),
        ).called(1);
      },
    );

    test('cleanup process renames .mustache files and formats code', () async {
      // This test implicitly checks the behavior of private methods _cleanup,
      // _ensureFileExtension, and _formatFiles.

      // Arrange
      final config = baseConfig.copyWith(barrelFiles: false);
      final upserts = config.copyWith();

      // Act
      // await overrideLogger(mockLogger, () async {
      await bundleGenerator.generateFiles(tempDir, upserts, config);
      // });

      // Assert
      // 1. Check that no .mustache files are left.
      final files = tempDir.listSync(recursive: true);
      for (final entity in files) {
        if (entity is File) {
          expect(p.extension(entity.path), isNot(equals('.mustache')));
        }
      }

      // 2. Check that dart format was called.
      verify(() => mockLogger.detail('Running dart format')).called(1);

      // 3. Check that files were logged as success.
      verify(
        () => mockLogger.success(any(that: contains('.dart'))),
      ).called(tables.length + enums.length);
    });
  });
}
