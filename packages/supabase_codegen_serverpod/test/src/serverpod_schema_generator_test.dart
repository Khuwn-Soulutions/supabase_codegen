import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';
import 'package:test/test.dart';
import '../../../supabase_codegen/test/src/generator/test_helpers/test_helpers.dart';

void main() {
  group('ServerpodSchemaGenerator', () {
    test('can be instantiated', () {
      expect(const ServerpodSchemaGenerator(), isA<ServerpodSchemaGenerator>());
    });

    test('uses SpyBundleGenerator', () {
      const generator = ServerpodSchemaGenerator();
      expect(generator.bundleGenerator, isA<SpyBundleGenerator>());
    });

    group('generateConfig', () {
      setUpAll(() {
        registerFallbackValue(GeneratorConfig.empty());
        registerFallbackValue(GeneratorLockfile.empty());
        registerFallbackValue(Directory.systemTemp.createTempSync());
      });

      setUp(() {
        client = mockSupabase;
      });

      test(
        'removes serverpod tables and disables barrel files logic',
        () async {
          const userTable = 'users';
          const postTable = 'posts';
          const serverpodHealth = 'serverpod_health';
          const serverpodMigrations = 'serverpod_migrations';

          final tables =
              [
                userTable,
                serverpodHealth,
                postTable,
                serverpodMigrations,
              ].fold(
                <Map<String, String?>>[],
                (tables, table) {
                  final schema = createTableSchema(table, [
                    {
                      'column_name': 'id',
                      'data_type': 'integer',
                      'is_nullable': 'NO',
                      'column_default': "nextval('my_table_id_seq'::regclass)",
                      'udt_name': 'int4',
                    },
                  ]);
                  tables.addAll(schema);
                  return tables;
                },
              );
          mockSchemaRpc(tables);
          mockEnumRpc([]);

          final params = GeneratorConfigParams.empty();

          const generator = ServerpodSchemaGenerator();

          final filteredConfig = await generator.generateConfig(params);

          expect(filteredConfig.barrelFiles, isFalse);
          expect(filteredConfig.tables, hasLength(2));
          expect(
            filteredConfig.tables.map((t) => t.name),
            containsAll([userTable, postTable]),
          );
          expect(
            filteredConfig.tables.map((t) => t.name),
            isNot(
              contains(
                anyOf(serverpodHealth, serverpodMigrations),
              ),
            ),
          );
        },
      );
    });
  });
}
