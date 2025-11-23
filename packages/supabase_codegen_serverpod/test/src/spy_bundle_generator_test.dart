import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/src/spy_bundle_generator.dart';
import 'package:test/test.dart';

void main() {
  createVerboseLogger();

  group('SpyBundleGenerator', () {
    late Directory tempDir;
    late Directory enumsDir;
    late Directory tablesDir;
    late SpyBundleGenerator codeGenerator;

    Future<void> generateTables(
      Map<String, List<Map<String, String?>>> schema,
    ) async {
      final tableConfigs = schema.entries
          .map(
            (entry) => TableConfig.fromFieldNameTypeMap(
              entry.key,
              createFieldNameTypeMap(entry.value),
            ),
          )
          .toList();
      final upserts = GeneratorConfig.empty().copyWith(
        tables: tableConfigs,
      );
      await codeGenerator.generateFiles(
        tempDir,
        upserts,
      );
    }

    setUp(() {
      logger = testLogger;
      codeGenerator = const SpyBundleGenerator();
      tempDir = Directory.systemTemp.createTempSync(
        'supabase_codegen_serverpod_test',
      );
      enumsDir = Directory(path.join(tempDir.path, 'enums'));
      tablesDir = Directory(path.join(tempDir.path, 'tables'));
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('generateFiles', () {
      test('creates correct files and content from provided map', () async {
        const enumName = 'my_values';
        const values = ['val1', 'val2'];
        final enumConfig = EnumConfig(
          enumName: enumName,
          formattedEnumName: enumName.toPascalCase(),
          values: values,
        );
        final upserts = GeneratorConfig.empty().copyWith(
          enums: [enumConfig],
        );
        await codeGenerator.generateFiles(
          tempDir,
          upserts,
        );

        const fileName = 'my_values.spy.yaml';

        final enumFile = File(path.join(enumsDir.path, fileName));
        expect(enumFile.existsSync(), isTrue);

        final content = await enumFile.readAsString();
        logger.info('Content: $content');
        expect(content, contains('enum: MyValues'));
        expect(content, contains('serialized: byName'));
        expect(content, contains('values:'));
        expect(content, contains(' - val1'));
        expect(content, contains(' - val2'));
      });

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
          await generateTables(tables);
          final tableFile = File(
            path.join(
              tablesDir.path,
              'students.spy.yaml',
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
        await generateTables(tables);

        final tableFile = File(
          path.join(
            tablesDir.path,
            'my_table.spy.yaml',
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
        await generateTables(tables);

        final tableFile = File(
          path.join(
            tablesDir.path,
            '$tableName.spy.yaml',
          ),
        );
        expect(tableFile.existsSync(), isTrue);

        final content = await tableFile.readAsString();
        expect(content, contains('createdAt: DateTime, column=created_at'));
      });
    });
  });
}
