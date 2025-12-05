import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen/src/supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

import '../test_helpers/test_helpers.dart';

class MockGeneratorLockfileManager extends Mock
    implements GeneratorLockfileManager {}

class MockBundleGenerator extends Mock implements BundleGenerator {}

void main() {
  setUpAll(() {
    registerFallbackValue(GeneratorConfig.empty());
    registerFallbackValue(GeneratorLockfile.empty());
    registerFallbackValue(Directory.systemTemp.createTempSync());
  });

  group('SupabaseSchemaGenerator', () {
    late SupabaseSchemaGenerator generator;
    late MockGeneratorLockfileManager mockLockfileManager;
    late MockBundleGenerator mockBundleGenerator;

    setUp(() {
      mockLockfileManager = MockGeneratorLockfileManager();
      mockBundleGenerator = MockBundleGenerator();
      generator = SupabaseSchemaGenerator(
        lockfileManager: mockLockfileManager,
        bundleGenerator: mockBundleGenerator,
      );
      client = mockSupabase;
      SupabaseSchemaGenerator.config = GeneratorConfig.empty();
    });

    group('generateConfig ', () {
      test('when schema and enum return valid values '
          'then returns a GeneratorConfig', () async {
        mockEnumRpc(testEnumOne);
        mockSchemaRpc(testTableSchema);
        mockGetRpc([]);
        final params = GeneratorConfigParams.empty().copyWith(
          package: 'package',
          version: 'version',
          forFlutter: true,
          tag: 'tag',
          barrelFiles: true,
        );
        final config = await generator.generateConfig(params);
        expect(config, isA<GeneratorConfig>());
        expect(config.package, params.package);
        expect(config.version, params.version);
        expect(config.forFlutter, params.forFlutter);
        expect(config.tag, params.tag);
        expect(config.barrelFiles, params.barrelFiles);
        expect(config.enums, isA<List<EnumConfig>>());
        expect(config.enums.length, 1);
        expect(config.tables, isA<List<TableConfig>>());
        expect(config.tables.length, 1);
      });

      test('when no tables in schema then an error is thrown', () {
        mockSchemaRpc([]);
        expect(
          () => generator.generateConfig(GeneratorConfigParams.empty()),
          throwsException,
        );
      });
    });

    group('generate', () {
      test('calls generateConfig, generateSchema and generateRpc '
          'and returns result', () async {
        // Arrange
        mockEnumRpc(testEnumOne);
        mockSchemaRpc(testTableSchema);
        mockGetRpc([testRpcJson]);

        final params = GeneratorConfigParams.empty();

        // Mocking dependencies of generateSchema
        when(() => mockLockfileManager.processLockFile(any())).thenAnswer(
          (_) async => (
            deletes: (enums: <String>[], tables: <String>[]),
            upserts: GeneratorConfig.empty(), // has upserts
            lockfile: GeneratorLockfile.empty(),
          ),
        );
        when(
          () => mockBundleGenerator.generateFiles(any(), any(), any()),
        ).thenAnswer((_) async {});
        when(
          () => mockLockfileManager.writeLockfile(
            lockfile: any(named: 'lockfile'),
          ),
        ).thenAnswer((_) => true);

        // Act
        final result = await generator.generate(params);

        // Assert
        expect(result, isTrue);
        // Verify that generateSchema's dependencies were called
        verify(() => mockLockfileManager.processLockFile(any())).called(1);
        verify(
          () => mockBundleGenerator.generateFiles(any(), any(), any()),
        ).called(1);
      });
    });

    group('generateSchema', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync();
        when(
          () => mockBundleGenerator.generateFiles(any(), any(), any()),
        ).thenAnswer((_) async {});
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test(
        'when no changes, returns false and does not generate files',
        () async {
          // Arrange
          when(() => mockLockfileManager.processLockFile(any())).thenAnswer(
            (_) async => (
              deletes: null,
              upserts: null,
              lockfile: GeneratorLockfile.empty(),
            ),
          );

          // Act
          final result = await generator.generateSchema(tempDir.path);

          // Assert
          expect(result, isFalse);
          verifyNever(
            () => mockBundleGenerator.generateFiles(any(), any(), any()),
          );
          verifyNever(
            () => mockLockfileManager.writeLockfile(
              lockfile: any(named: 'lockfile'),
            ),
          );
        },
      );

      test('when only upserts, generates files and returns true', () async {
        // Arrange
        final upserts = GeneratorConfig.empty();
        when(() => mockLockfileManager.processLockFile(any())).thenAnswer(
          (_) async => (
            deletes: null,
            upserts: upserts,
            lockfile: GeneratorLockfile.empty(),
          ),
        );

        // Act
        final result = await generator.generateSchema(tempDir.path);

        // Assert
        expect(result, isTrue);
        verify(
          () => mockBundleGenerator.generateFiles(
            any(that: isA<Directory>()),
            upserts,
            any(that: isA<GeneratorConfig>()),
          ),
        ).called(1);
        verify(
          () => mockLockfileManager.writeLockfile(
            lockfile: any(named: 'lockfile'),
          ),
        ).called(1);
      });

      test('when only deletes, deletes files and returns true', () async {
        // Arrange
        const enumFile = 'my_enum.dart';
        final deletes = (enums: [enumFile], tables: <String>[]);
        final fileToDelete = File(path.join(tempDir.path, enumFile));
        await fileToDelete.create();
        expect(fileToDelete.existsSync(), isTrue);

        when(() => mockLockfileManager.processLockFile(any())).thenAnswer(
          (_) async => (
            deletes: deletes,
            upserts: null,
            lockfile: GeneratorLockfile.empty(),
          ),
        );

        // Act
        final result = await generator.generateSchema(tempDir.path);

        // Assert
        expect(result, isTrue);
        expect(fileToDelete.existsSync(), isFalse);
        verifyNever(
          () => mockBundleGenerator.generateFiles(any(), any(), any()),
        );
        verify(
          () => mockLockfileManager.writeLockfile(
            lockfile: any(named: 'lockfile'),
          ),
        ).called(1);
      });

      test('when upserts and deletes, generates and deletes files', () async {
        // Arrange
        final upserts = GeneratorConfig.empty();
        const enumFile = 'my_enum.dart';
        final deletes = (enums: [enumFile], tables: <String>[]);
        final fileToDelete = File(path.join(tempDir.path, enumFile));
        await fileToDelete.create();
        expect(fileToDelete.existsSync(), isTrue);

        when(() => mockLockfileManager.processLockFile(any())).thenAnswer(
          (_) async => (
            deletes: deletes,
            upserts: upserts,
            lockfile: GeneratorLockfile.empty(),
          ),
        );

        // Act
        final result = await generator.generateSchema(tempDir.path);

        // Assert
        expect(result, isTrue);
        expect(fileToDelete.existsSync(), isFalse);
        verify(
          () => mockBundleGenerator.generateFiles(
            any(that: isA<Directory>()),
            upserts,
            any(that: isA<GeneratorConfig>()),
          ),
        ).called(1);
        verify(
          () => mockLockfileManager.writeLockfile(
            lockfile: any(named: 'lockfile'),
          ),
        ).called(1);
      });
    });

    group('writeLockFile', () {
      test('calls lockfileManager.writeLockfile', () {
        // Arrange
        final lockfile = GeneratorLockfile.empty();

        // Act
        generator.writeLockFile(lockfile);

        // Assert
        verify(
          () => mockLockfileManager.writeLockfile(lockfile: lockfile),
        ).called(1);
      });

      test('does not throw on exception from lockfileManager', () {
        // Arrange
        final lockfile = GeneratorLockfile.empty();
        final exception = Exception('Failed to write');
        when(
          () => mockLockfileManager.writeLockfile(lockfile: lockfile),
        ).thenThrow(exception);

        // Act & Assert
        expect(() => generator.writeLockFile(lockfile), returnsNormally);
        verify(
          () => mockLockfileManager.writeLockfile(lockfile: lockfile),
        ).called(1);
      });
    });
  });
}
