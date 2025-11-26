import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';
import 'package:test/test.dart';

import '../../../supabase_codegen/test/src/generator/test_helpers/test_helpers.dart';

class MockGeneratorLockfileManager extends Mock
    implements GeneratorLockfileManager {}

void main() {
  group('ServerpodCodeGenerator', () {
    test('can be instantiated', () {
      expect(const ServerpodCodeGenerator(), isNotNull);
    });

    test('bundle generator is of type SpyBundleGenerator', () {
      const generator = ServerpodCodeGenerator();
      expect(
        generator.schemaGenerator.bundleGenerator,
        isA<SpyBundleGenerator>(),
      );
    });

    group('schemaGenerator', () {
      setUpAll(() {
        registerFallbackValue(GeneratorConfig.empty());
        registerFallbackValue(GeneratorLockfile.empty());
        registerFallbackValue(Directory.systemTemp.createTempSync());
      });

      late MockGeneratorLockfileManager mockLockfileManager;
      late Directory tempDir;

      setUp(() {
        mockLockfileManager = MockGeneratorLockfileManager();
        client = mockSupabase;
        SupabaseSchemaGenerator.config = GeneratorConfig.empty();

        tempDir = Directory.systemTemp.createTempSync(
          'supabase_codegen_serverpod_test',
        );
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test('runs full generation creating all files', () async {
        // Arrange
        final tables = [
          ...createTableSchema('my_table', [
            {
              'column_name': 'id',
              'data_type': 'integer',
              'is_nullable': 'NO',
              'column_default': "nextval('my_table_id_seq'::regclass)",
              'udt_name': 'int4',
            },
            {
              'column_name': 'name',
              'data_type': 'text',
              'is_nullable': 'YES',
              'column_default': null,
              'udt_name': 'text',
            },
            {
              'column_name': 'type',
              'data_type': 'USER-DEFINED',
              'udt_name': 'my_values',
              'is_nullable': 'NO',
              'column_default': null,
            },
            {
              'column_name': 'maybe_type',
              'data_type': 'USER-DEFINED',
              'udt_name': 'choices',
              'is_nullable': 'YES',
              'column_default': null,
            },
          ]),
          ...createTableSchema(
            'another_table',
            [
              {
                'column_name': 'id',
                'data_type': 'String',
                'is_nullable': 'NO',
                'column_default': 'gen_random_uuid()',
                'udt_name': 'uuid',
              },
            ],
          ),
          ...createTableSchema(
            'recipes',
            [
              {
                'column_name': 'id',
                'data_type': 'String',
                'is_nullable': 'NO',
                'column_default': 'gen_random_uuid()',
                'udt_name': 'uuid',
              },
              {
                'column_name': 'created_at',
                'data_type': 'timestamptz',
                'is_nullable': 'NO',
                'column_default': null,
                'udt_name': 'timestamp with time zone',
              },
            ],
          ),
        ];

        final enums = [
          ...createEnumSchema('my_values', ['value1', 'value2']),
          ...createEnumSchema('choices', ['a', 'b', 'c']),
        ];
        final enumsDir = Directory(path.join(tempDir.path, 'enums'));
        final tablesDir = Directory(path.join(tempDir.path, 'tables'));
        final codeGenerator = ServerpodCodeGenerator(
          schemaGenerator: SupabaseSchemaGenerator(
            bundleGenerator: const SpyBundleGenerator(),
            lockfileManager: mockLockfileManager,
          ),
        );
        final params = GeneratorConfigParams.empty().copyWith(
          package: 'package',
          version: 'version',
          forFlutter: false,
          barrelFiles: false,
          outputFolder: tempDir.path,
        );
        mockEnumRpc(enums);
        mockSchemaRpc(tables);
        mockGetRpc([]);

        when(() => mockLockfileManager.processLockFile(any())).thenAnswer(
          (inv) async => (
            deletes: (enums: <String>[], tables: <String>[]),
            upserts: inv.positionalArguments.first as GeneratorConfig,
            lockfile: GeneratorLockfile.empty(),
          ),
        );
        when(
          () => mockLockfileManager.writeLockfile(
            lockfile: any(named: 'lockfile'),
          ),
        ).thenAnswer((_) => true);

        // Act
        await codeGenerator.schemaGenerator.generate(params);

        // Assert

        // Check enums
        final enumFile = File(
          path.join(
            enumsDir.path,
            'my_values.spy.yaml',
          ),
        );
        expect(enumFile.existsSync(), isTrue);
        final enumContent = await enumFile.readAsString();
        expect(enumContent, contains('enum: MyValues'));
        expect(enumContent, contains(' - value1'));

        final anotherEnumFile = File(
          path.join(
            enumsDir.path,
            'choices.spy.yaml',
          ),
        );
        expect(anotherEnumFile.existsSync(), isTrue);
        final anotherEnumContent = await anotherEnumFile.readAsString();
        expect(anotherEnumContent, contains('enum: Choices'));
        expect(anotherEnumContent, contains(' - a'));

        // Check tables
        final tableFile = File(
          path.join(
            tablesDir.path,
            'my_table.spy.yaml',
          ),
        );
        expect(tableFile.existsSync(), isTrue);
        final tableContent = await tableFile.readAsString();
        expect(tableContent, contains('class: MyTable'));
        expect(tableContent, contains('  id: int?'));
        expect(tableContent, contains('  name: String?'));
        expect(tableContent, contains('  type: MyValues'));
        expect(tableContent, contains('  maybeType: Choices?'));

        final anotherTableFile = File(
          path.join(
            tablesDir.path,
            'another_table.spy.yaml',
          ),
        );
        expect(anotherTableFile.existsSync(), isTrue);
        final anotherTableContent = await anotherTableFile.readAsString();
        expect(anotherTableContent, contains('class: AnotherTable'));
        expect(
          anotherTableContent,
          contains('  id: UuidValue?, defaultPersist=random'),
        );

        final recipesFile = File(
          path.join(
            tablesDir.path,
            'recipes.spy.yaml',
          ),
        );
        expect(recipesFile.existsSync(), isTrue);
        final recipesContent = await recipesFile.readAsString();
        expect(recipesContent, contains('class: Recipe'));
        expect(
          recipesContent,
          contains('  id: UuidValue?, defaultPersist=random'),
        );
        expect(
          recipesContent,
          contains('  createdAt: DateTime, column=created_at'),
        );
      });
    });
  });
}
