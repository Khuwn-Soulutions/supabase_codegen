import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

import '../test_helpers/mock_data.dart';

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
      TableConfig(
        name: 'users',
        columns: [
          ColumnConfig.fromColumnData(
            fieldName: 'id',
            columnData: (
              dartType: 'int',
              isNullable: false,
              hasDefault: false,
              defaultValue: null,
              columnName: 'id',
              isArray: false,
              isEnum: false,
            ),
          ),
          ColumnConfig.fromColumnData(
            fieldName: 'name',
            columnData: (
              dartType: 'String',
              isNullable: true,
              hasDefault: true,
              defaultValue: 'some default',
              columnName: 'name',
              isArray: false,
              isEnum: false,
            ),
          ),
          ColumnConfig.fromColumnData(
            fieldName: 'createdAt',
            columnData: (
              dartType: 'DateTime',
              isNullable: false,
              hasDefault: true,
              defaultValue: 'now()',
              columnName: 'created_at',
              isArray: false,
              isEnum: false,
            ),
          ),
          ColumnConfig.fromColumnData(
            fieldName: 'tags',
            columnData: (
              dartType: 'List<String>',
              isNullable: true,
              hasDefault: false,
              defaultValue: null,
              columnName: 'tags',
              isArray: true,
              isEnum: false,
            ),
          ),
        ],
      ),
    ];
    final enums = [
      const EnumConfig(
        formattedEnumName: 'UserStatus',
        enumName: 'User_Status',
        values: ['active', 'inactive'],
      ),
    ];
    final rpcs = [
      RpcConfig(
        functionName: 'get_rpc_functions',
        args: const <RpcFieldConfig>[],
        returnType: RpcReturnTypeConfig.empty(),
      ),
    ];
    final baseConfig = GeneratorConfig.empty().copyWith(
      tables: tables,
      enums: enums,
      rpcs: rpcs,
    );
    late File databaseFile;
    late Directory enumsDir;
    late Directory tablesDir;
    late File tablesBarrelFile;
    late File enumsBarrelFile;
    late File rpcsBarrelFile;

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
      rpcsBarrelFile = File(p.join(tempDir.path, 'rpcs/_rpcs.dart'));
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('generateFiles creates tables, enums, rpcs, and barrel files '
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
      expect(
        rpcsBarrelFile.existsSync(),
        isTrue,
        reason: 'rpcs barrel file should exist',
      );

      verify(
        () => mockLogger.progress('Generating Tables and Enums...'),
      ).called(1);
      verify(() => mockProgress.update('Generating barrel files')).called(1);
      verify(
        () => mockLogger.progress('Cleaning up generated files'),
      ).called(1);
    });

    group('when barrelFiles is false', () {
      test('creates only rpcs, tables and enums', () async {
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
        expect(rpcsBarrelFile.existsSync(), isFalse);

        verify(
          () => mockLogger.progress('Generating Tables and Enums...'),
        ).called(1);
        verifyNever(() => mockProgress.update('Generating barrel files'));
        verify(
          () => mockLogger.progress('Cleaning up generated files'),
        ).called(1);
      });

      test('creates only tables if no enums or rpcs are provided', () async {
        // Arrange
        final config = baseConfig.copyWith(
          enums: [],
          rpcs: [],
          barrelFiles: false,
        );
        final upserts = config.copyWith();

        // Act
        await bundleGenerator.generateFiles(tempDir, upserts, config);

        // Assert
        expect(enumsDir.existsSync(), isFalse);
        expect(tablesDir.existsSync(), isTrue);
        expect(databaseFile.existsSync(), isFalse);
        expect(tablesBarrelFile.existsSync(), isFalse);
        expect(enumsBarrelFile.existsSync(), isFalse);
        expect(rpcsBarrelFile.existsSync(), isFalse);

        verify(
          () => mockLogger.progress('Generating Tables and Enums...'),
        ).called(1);
        verifyNever(() => mockProgress.update('Generating barrel files'));
        verify(
          () => mockLogger.progress('Cleaning up generated files'),
        ).called(1);
      });
    });

    test('cleanup process renames .mustache files and formats code', () async {
      // This test implicitly checks the behavior of private methods _cleanup,
      // _ensureFileExtension, and _formatFiles.

      // Arrange
      final config = baseConfig.copyWith(barrelFiles: false);
      final upserts = config.copyWith();

      // Act
      final generatedFiles = await bundleGenerator.generateFiles(
        tempDir,
        upserts,
        config,
      );

      // Assert
      // 1. Check that no .mustache files are in the output folder.
      final files = tempDir.listSync(recursive: true);
      for (final entity in files) {
        if (entity is File) {
          expect(p.extension(entity.path), isNot(equals('.mustache')));
        }
      }

      // 2. Check that dart format was called.
      verify(() => mockLogger.detail('Running dart format')).called(1);

      // 3. Check that files were generated with the correct extension.
      final totalFiles = tables.length + enums.length + rpcs.length;
      expect(generatedFiles.length, equals(totalFiles));
      expect(
        generatedFiles.every((file) => file.path.endsWith(dartFileType)),
        isTrue,
      );
      // 4. Check that files were logged as success.
      verify(
        () => mockLogger.success(any(that: contains(dartFileType))),
      ).called(totalFiles);
    });

    group('when files are generated', () {
      late List<File> expectedFiles;

      setUp(() async {
        final rpcs = testRpcFunctionsData
            .map(
              (json) => RpcConfig(
                functionName: json['function_name'] ?? '',
                args: parseArguments(json['arguments'] ?? ''),
                returnType: parseReturnType(
                  json['return_type'] ?? '',
                  tables: tables,
                ),
              ),
            )
            .toList();

        // Arrange
        final config = baseConfig.copyWith(
          barrelFiles: true,
          rpcs: rpcs,
          package: defaultPackageName,
        );
        final upserts = config.copyWith();

        expectedFiles = [
          databaseFile,
          enumsBarrelFile,
          tablesBarrelFile,
          rpcsBarrelFile,
          for (final table in tables)
            File(p.join(tablesDir.path, '${table.name}.dart')),
          for (final enumConfig in enums)
            File(p.join(enumsDir.path, '${enumConfig.fileName}.dart')),
          for (final rpc in rpcs)
            File(p.join(tempDir.path, rpcsFolder, '${rpc.functionName}.dart')),
        ];

        // Act (generate files before each test in this group)
        await bundleGenerator.generateFiles(tempDir, upserts, config);
      });

      test('generates expected file names', () async {
        // Assert
        for (final file in expectedFiles) {
          expect(
            file.existsSync(),
            isTrue,
            reason: '${file.path} should exist',
          );
        }
      });

      test('generates expected file contents', () async {
        // Function to remove date line from file contents
        String withoutDateLine(String contents) =>
            contents.replaceAll(RegExp(r'\s*// Date:.*\n'), '').trim();

        // Assert
        for (final file in expectedFiles) {
          final relativePath = file.path.replaceFirst(
            tempDir.path,
            'test/src/generator/test_helpers/generated_files',
          );
          final expectedFile = File(relativePath);
          expect(
            expectedFile.existsSync(),
            isTrue,
            reason: '${expectedFile.path} should exist',
          );
          final fileWithoutDate = withoutDateLine(file.readAsStringSync());
          final expectedFileWithoutDate = withoutDateLine(
            expectedFile.readAsStringSync(),
          );
          expect(fileWithoutDate, expectedFileWithoutDate);
        }
      });
    });

    test('when file generation fails, error propagated', () async {
      // Act & Assert - error is thrown
      await expectLater(
        () => bundleGenerator.generateFiles(
          tempDir,
          baseConfig,
          baseConfig,
          // unmodifiable list triggers generation failure
          List.unmodifiable([]),
        ),
        throwsA(isA<Error>()),
      );

      // Assert - progress was marked as failed
      verify(
        () => mockProgress.fail(any(that: contains('Generation failed'))),
      ).called(1);
    });
  });
}
