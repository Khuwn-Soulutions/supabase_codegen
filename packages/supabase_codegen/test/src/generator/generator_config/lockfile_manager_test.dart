import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

void main() {
  group('GeneratorLockfileManager', () {
    late Directory tempDir;
    late GeneratorLockfileManager lockfileManager;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync();
      lockfileManager = const GeneratorLockfileManager();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    final table1 = TableConfig(
      name: 'table1',
      columns: [
        ColumnConfig.empty().copyWith(
          columnName: 'col1',
          dartType: DartType.string,
        ),
      ],
    );
    final table2 = TableConfig(
      name: 'table2',
      columns: [
        ColumnConfig.empty().copyWith(
          columnName: 'col2',
          dartType: DartType.int,
        ),
      ],
    );
    final enum1 = EnumConfig.empty().copyWith(
      enumName: 'enum1',
      formattedEnumName: 'enum1',
      values: ['val1', 'val2'],
    );
    final enum2 = EnumConfig.empty().copyWith(
      enumName: 'enum2',
      formattedEnumName: 'enum2',
      values: ['valA', 'valB'],
    );

    final baseConfig = GeneratorConfig(
      package: 'test_pkg',
      version: '1.0.0',
      forFlutter: false,
      tag: 'test',
      barrelFiles: true,
      tables: [table1],
      enums: [enum1],
    );
    final baseLockfile = GeneratorLockfile.fromConfig(baseConfig);

    group('processLockFile', () {
      group('given no previous lockfile', () {
        test(
          'then upserts matches the provided config and no deletes are present',
          () async {
            final result = await lockfileManager.processLockFile(
              baseConfig,
              directory: tempDir,
            );

            expect(result.upserts, equals(baseConfig));
            expect(result.deletes, isNull);
            expect(result.lockfile, isNotNull);
          },
        );
      });
      group('given a previous lockfile', () {
        test('when the config is the same as the previous lockfile '
            'then there are no upserts or deletes', () async {
          // Write initial lockfile
          lockfileManager.writeLockfile(
            lockfile: baseLockfile,
            directory: tempDir,
          );

          final result = await lockfileManager.processLockFile(
            baseConfig,
            directory: tempDir,
          );

          expect(result.upserts, isNull);
          expect(result.deletes, isNull);
        });

        group('when the config data changes and', () {
          test('a table is added then there is an upsert', () async {
            lockfileManager.writeLockfile(
              lockfile: baseLockfile,
              directory: tempDir,
            );

            final newConfig = baseConfig.copyWith(tables: [table1, table2]);
            final result = await lockfileManager.processLockFile(
              newConfig,
              directory: tempDir,
            );

            expect(result.upserts?.tables, contains(table2));
            expect(result.upserts?.tables.length, 1);
            expect(result.upserts?.enums, isEmpty);
            expect(result.deletes, isNull);
          });
          test('a table is removed then its name is in deletes', () async {
            final initialConfig = baseConfig.copyWith(tables: [table1, table2]);
            lockfileManager.writeLockfile(
              lockfile: GeneratorLockfile.fromConfig(initialConfig),
              directory: tempDir,
            );

            final currentConfig = baseConfig.copyWith(tables: [table1]);
            final result = await lockfileManager.processLockFile(
              currentConfig,
              directory: tempDir,
            );
            expect(result.deletes, isNotNull);
            expect(
              result.deletes,
              contains(path.join(tablesFolder, '${table2.name}.dart')),
            );
          });

          test('a table is modified then there is an upsert', () async {
            lockfileManager.writeLockfile(
              lockfile: baseLockfile,
              directory: tempDir,
            );

            final modifiedTable1 = table1.copyWith(
              columns: [
                ColumnConfig.empty().copyWith(
                  columnName: 'col1',
                  dartType: DartType.int,
                ),
                ColumnConfig.empty().copyWith(
                  columnName: 'new_col',
                  dartType: DartType.bool,
                ),
              ],
            );
            final newConfig = baseConfig.copyWith(tables: [modifiedTable1]);
            final result = await lockfileManager.processLockFile(
              newConfig,
              directory: tempDir,
            );

            expect(result.upserts?.tables, contains(modifiedTable1));
            expect(result.upserts?.tables.length, 1);
            expect(result.deletes, isNull);
          });

          test('an enum is added then there is an upsert', () async {
            lockfileManager.writeLockfile(
              lockfile: baseLockfile,
              directory: tempDir,
            );

            final newConfig = baseConfig.copyWith(enums: [enum1, enum2]);
            final result = await lockfileManager.processLockFile(
              newConfig,
              directory: tempDir,
            );

            expect(result.upserts?.enums, contains(enum2));
            expect(result.upserts?.enums.length, 1);
            expect(result.upserts?.tables, isEmpty);
            expect(result.deletes, isNull);
          });

          test('an enum is removed then its filename is in deletes', () async {
            final initialConfig = baseConfig.copyWith(enums: [enum1, enum2]);
            lockfileManager.writeLockfile(
              lockfile: GeneratorLockfile.fromConfig(initialConfig),
              directory: tempDir,
            );

            final currentConfig = baseConfig.copyWith(enums: [enum1]);
            final result = await lockfileManager.processLockFile(
              currentConfig,
              directory: tempDir,
            );
            expect(result.deletes, isNotNull);
            expect(
              result.deletes,
              contains(path.join(enumsFolder, '${enum2.fileName}.dart')),
            );
          });

          test('an enum is modified then there is an upsert', () async {
            lockfileManager.writeLockfile(
              lockfile: baseLockfile,
              directory: tempDir,
            );

            final modifiedEnum1 = enum1.copyWith(
              values: ['val1', 'val2', 'new_val'],
            );
            final newConfig = baseConfig.copyWith(enums: [modifiedEnum1]);
            final result = await lockfileManager.processLockFile(
              newConfig,
              directory: tempDir,
            );

            expect(result.upserts?.enums, contains(modifiedEnum1));
            expect(result.upserts?.enums.length, 1);
            expect(result.deletes, isNull);
          });

          test('there are mixed enum and table changes then there are '
              'upserts and deletes', () async {
            final initialConfig = baseConfig.copyWith(
              tables: [table1, table2],
              enums: [enum1],
            );
            lockfileManager.writeLockfile(
              lockfile: GeneratorLockfile.fromConfig(initialConfig),
              directory: tempDir,
            );

            final modifiedTable1 = table1.copyWith(
              columns: [
                ColumnConfig.empty().copyWith(
                  columnName: 'col1_mod',
                  dartType: DartType.double,
                ),
              ],
            );
            // table2 is removed
            // enum1 is unchanged
            // enum2 is added
            final newConfig = baseConfig.copyWith(
              tables: [modifiedTable1],
              enums: [enum1, enum2],
            );

            final result = await lockfileManager.processLockFile(
              newConfig,
              directory: tempDir,
            );

            // Upserts: modified table1 and added enum2
            expect(result.upserts?.tables.length, 1);
            expect(result.upserts?.tables.first.name, 'table1');
            expect(result.upserts?.enums.length, 1);
            expect(result.upserts?.enums.first.enumName, 'enum2');

            expect(result.deletes, isNotNull);
            expect(
              result.deletes,
              contains(path.join(tablesFolder, '${table2.name}.dart')),
            );
          });
        });

        group('when the config', () {
          test('date is modified there are no upserts or deletes', () async {
            // Write initial lockfile
            lockfileManager.writeLockfile(
              lockfile: baseLockfile.copyWith(date: DateTime.now()),
              directory: tempDir,
            );

            final result = await lockfileManager.processLockFile(
              baseConfig,
              directory: tempDir,
            );

            expect(result.upserts, isNull);
            expect(result.deletes, isNull);
          });

          final changes = [
            (field: 'package', value: 'different_package'),
            (field: 'version', value: '2.0.0'),
            (field: 'forFlutter', value: !baseConfig.forFlutter),
            (field: 'tag', value: 'different_tag'),
            (field: 'barrelFiles', value: !baseConfig.barrelFiles),
          ];

          for (final (:field, :value) in changes) {
            test('$field is modified then all current tables '
                'and enums are upserted and no deletes are present', () async {
              // Write initial lockfile
              lockfileManager.writeLockfile(
                lockfile: baseLockfile,
                directory: tempDir,
              );

              final tables = [table1, table2];
              final enums = [enum1, enum2];

              final newConfig = GeneratorConfig.fromJson({
                ...baseConfig.toJson(),
                field: value,
              }).copyWith(tables: tables, enums: enums);

              final result = await lockfileManager.processLockFile(
                newConfig,
                directory: tempDir,
              );
              expect(result.upserts, equals(newConfig));
              expect(result.upserts?.tables, equals(tables));
              expect(result.upserts?.enums, equals(enums));
              expect(result.deletes, isNull);
            });
          }
        });
      });
    });
  });
}
