import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/src/codegen_utils.dart';
import 'package:test/test.dart';

void main() {
  const tables = {
    'my_table': [
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
    ],
    'another_table': [
      {
        'column_name': 'id',
        'data_type': 'String',
        'is_nullable': 'NO',
        'column_default': 'gen_random_uuid()',
        'udt_name': 'uuid',
      },
    ],
    'recipes': [
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
  };

  const enums = {
    'my_values': ['value1', 'value2'],
    'choices': ['a', 'b', 'c'],
  };

  group('SupabaseCodeGenServerpodUtils', () {
    late Directory tempDir;
    late SupabaseCodeGenServerpodUtils codeGenerator;
    late Directory enumsDir;
    late Directory tablesDir;

    setUp(() {
      packageName = 'supabase_codegen_serverpod';
      logger = testLogger;
      tempDir = Directory.systemTemp.createTempSync(
        'supabase_codegen_serverpod_test',
      );
      root = tempDir.path;
      codeGenerator = const SupabaseCodeGenServerpodUtils();
      enumsDir = Directory(path.join(tempDir.path, enumsDirectoryName))
        ..createSync(recursive: true);
      tablesDir = Directory(path.join(tempDir.path, tablesDirectoryName))
        ..createSync(recursive: true);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
      packageName = defaultPackageName;
    });

    test('writeSpyHeader writes correct header', () {
      final buffer = StringBuffer();
      codeGenerator.writeSpyHeader(buffer);
      final content = buffer.toString();
      expect(content, startsWith(SupabaseCodeGenServerpodUtils.commentPrefix));
      expect(content, contains(packageName));
    });

    test('writeSpyFooter writes correct footer', () {
      final buffer = StringBuffer();
      codeGenerator.writeSpyFooter(buffer);
      expect(
        buffer.toString(),
        startsWith(SupabaseCodeGenServerpodUtils.commentPrefix),
      );
    });

    group('generateEnumFiles', () {
      test('creates correct files and content from provided map', () async {
        const enumName = 'my_values';
        final enums = {
          enumName: ['val1', 'val2'],
        };
        await codeGenerator.generateEnumFiles(enums);

        const fileName = 'my_values.${SupabaseCodeGenServerpodUtils.fileType}';

        final enumFile = File(path.join(enumsDir.path, fileName));
        expect(enumFile.existsSync(), isTrue);

        final content = await enumFile.readAsString();
        expect(content, contains('enum: MyValues'));
        expect(content, contains('serialized: byName'));
        expect(content, contains('values:'));
        expect(content, contains(' - val1'));
        expect(content, contains(' - val2'));
      });
    });

    group('generateTableFiles', () {
      test(
        'creates file with classname singular version of table name',
        () async {
          final tables = {
            'students': [
              {
                'column_name': 'id',
                'data_type': 'integer',
                'is_nullable': 'NO',
                'column_default': "nextval('students_id_seq'::regclass)",
                'udt_name': 'int4',
              },
              {
                'column_name': 'name',
                'data_type': 'text',
                'is_nullable': 'YES',
                'column_default': null,
                'udt_name': 'text',
              },
            ],
          };
          await codeGenerator.generateTableFiles(tables);

          final tableFile = File(
            path.join(
              tablesDir.path,
              'students.${SupabaseCodeGenServerpodUtils.fileType}',
            ),
          );
          expect(tableFile.existsSync(), isTrue);

          final content = await tableFile.readAsString();
          expect(content, contains('class: Student'));
          expect(content, contains('table: students'));
        },
      );
      test('creates correct files and content from provided map', () async {
        final tables = {
          'my_table': [
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
          ],
        };
        await codeGenerator.generateTableFiles(tables);

        final tableFile = File(
          path.join(
            tablesDir.path,
            'my_table.${SupabaseCodeGenServerpodUtils.fileType}',
          ),
        );
        expect(tableFile.existsSync(), isTrue);

        final content = await tableFile.readAsString();
        expect(content, contains('class: MyTable'));
        expect(content, contains('table: my_table'));
        expect(content, contains('fields:'));
        expect(content, contains('  id: int?'));
        expect(content, contains('  name: String?'));
      });

      test('specifies the column name if originally in snake_case', () async {
        const tableName = 'recipes';
        final tables = {
          tableName: [
            {
              'column_name': 'created_at',
              'data_type': 'timestamptz',
              'is_nullable': 'NO',
              'column_default': null,
              'udt_name': 'timestamp with time zone',
            },
          ],
        };
        await codeGenerator.generateTableFiles(tables);

        final tableFile = File(
          path.join(
            tablesDir.path,
            '$tableName.${SupabaseCodeGenServerpodUtils.fileType}',
          ),
        );
        expect(tableFile.existsSync(), isTrue);

        final content = await tableFile.readAsString();
        expect(content, contains('createdAt: DateTime, column=created_at'));
      });
    });

    group('generateSchema', () {
      test('runs full generation creating all files', () async {
        await codeGenerator.generateSchema(
          enumsDir: enumsDir,
          tablesDir: tablesDir,
          enums: enums,
          schemaTables: tables,
        );

        // Check enums
        final enumFile = File(
          path.join(
            enumsDir.path,
            'my_values.${SupabaseCodeGenServerpodUtils.fileType}',
          ),
        );
        expect(enumFile.existsSync(), isTrue);
        final enumContent = await enumFile.readAsString();
        expect(enumContent, contains('enum: MyValues'));
        expect(enumContent, contains(' - value1'));

        final anotherEnumFile = File(
          path.join(
            enumsDir.path,
            'choices.${SupabaseCodeGenServerpodUtils.fileType}',
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
            'my_table.${SupabaseCodeGenServerpodUtils.fileType}',
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
            'another_table.${SupabaseCodeGenServerpodUtils.fileType}',
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
            'recipes.${SupabaseCodeGenServerpodUtils.fileType}',
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

    group('defaultModifierFor', () {
      final defaultValues = {
        'now()': (
          dartType: 'DateTime',
          expected: 'now',
        ),
        'gen_random_uuid()': (
          dartType: 'UuidValue',
          expected: 'random',
        ),
        'gen_random_uuid_v7()': (
          dartType: 'UuidValue',
          expected: 'random_v7',
        ),
        "nextval('table_id_seq'::regclass)": (
          dartType: 'int',
          expected: 'serial',
        ),
        "'10.5'::double precision": (
          dartType: 'double',
          expected: '10.5',
        ),
        "'10'::bigint": (
          dartType: 'int',
          expected: '10',
        ),
        "'This is a string'::text": (
          dartType: 'String',
          expected: "'This is a string'",
        ),
        'true': (dartType: 'bool', expected: 'true'),
        'false': (dartType: 'bool', expected: 'false'),
        null: (dartType: 'String', expected: ''),
      };

      for (final entry in defaultValues.entries) {
        final defaultValue = entry.key;
        final (:dartType, :expected) = entry.value;
        test('returns the correct default modifier for $defaultValue', () {
          final modifier = codeGenerator.defaultModifierFor(
            defaultValue,
            dartType: dartType,
            isId: false,
          );
          const defaultIdentifier =
              SupabaseCodeGenServerpodUtils.defaultIdentifier;
          expect(
            modifier,
            expected.isEmpty ? '' : ', $defaultIdentifier=$expected',
          );
        });
      }

      test('returns the correct default modifier for id', () {
        const defaultValue = "nextval('some_id_seq'::regclass)";
        const dartType = 'int';
        const expected = 'serial';
        final modifier = codeGenerator.defaultModifierFor(
          defaultValue,
          dartType: dartType,
          isId: true,
        );
        const defaultIdentifier =
            SupabaseCodeGenServerpodUtils.defaultPersistIdentifier;
        expect(
          modifier,
          ', $defaultIdentifier=$expected',
        );
      });
    });
  });
}
