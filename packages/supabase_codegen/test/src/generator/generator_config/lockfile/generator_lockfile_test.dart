import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'lockfile_mock_data.dart';

void main() {
  group('GeneratorLockfile', () {
    final date = DateTime.now();
    const package = 'test_package';
    const version = '1.0.0';
    const forFlutter = true;
    const tag = 'test_tag';
    const barrelFiles = true;
    final tables = {'my_table': 12345};
    final enums = {'my_enum': 54321};
    final rpcs = {'my_rpc': 67890};

    final lockfile = GeneratorLockfile(
      date: date,
      package: package,
      version: version,
      forFlutter: forFlutter,
      tag: tag,
      barrelFiles: barrelFiles,
      tables: tables,
      enums: enums,
      rpcs: rpcs,
    );

    test('can be instantiated', () {
      expect(lockfile, isNotNull);
    });

    group('empty', () {
      test('creates an empty lockfile', () {
        final emptyLockfile = GeneratorLockfile.empty();
        expect(emptyLockfile.package, isEmpty);
        expect(emptyLockfile.version, isEmpty);
        expect(emptyLockfile.forFlutter, isFalse);
        expect(emptyLockfile.tag, isEmpty);
        expect(emptyLockfile.barrelFiles, isFalse);
        expect(emptyLockfile.tables, isEmpty);
        expect(emptyLockfile.enums, isEmpty);
        expect(emptyLockfile.rpcs, isEmpty);
      });
    });

    group('fromJson', () {
      test('creates a lockfile from json', () {
        final json = {
          'date': date.toIso8601String(),
          'package': package,
          'version': version,
          'forFlutter': forFlutter,
          'tag': tag,
          'barrelFiles': barrelFiles,
          'tables': tables,
          'enums': enums,
          'rpcs': rpcs,
        };
        final fromJson = GeneratorLockfile.fromJson(json);
        expect(fromJson, equals(lockfile));
      });

      test('sets empty tag to empty string if null', () {
        final json = {
          'date': date.toIso8601String(),
          'package': package,
          'version': version,
          'forFlutter': forFlutter,
          'barrelFiles': barrelFiles,
          'tables': tables,
          'enums': enums,
          'rpcs': rpcs,
        };
        final fromJson = GeneratorLockfile.fromJson(json);
        expect(fromJson.tag, isEmpty);
      });

      test('sets tables to empty map if null', () {
        final json = {
          'date': date.toIso8601String(),
          'package': package,
          'version': version,
          'forFlutter': forFlutter,
          'barrelFiles': barrelFiles,
          'enums': enums,
          'rpcs': rpcs,
        };
        final fromJson = GeneratorLockfile.fromJson(json);
        expect(fromJson.tables, isEmpty);
      });

      test('sets enums to empty map if null', () {
        final json = {
          'date': date.toIso8601String(),
          'package': package,
          'version': version,
          'forFlutter': forFlutter,
          'barrelFiles': barrelFiles,
          'tables': tables,
          'rpcs': rpcs,
        };
        final fromJson = GeneratorLockfile.fromJson(json);
        expect(fromJson.enums, isEmpty);
      });
    });

    group('fromYaml', () {
      test('creates a lockfile from yaml', () {
        final yaml =
            '''
date: ${date.toIso8601String()}
package: $package
version: $version
forFlutter: $forFlutter
barrelFiles: $barrelFiles
tag: $tag
tables:
  my_table: 12345
enums:
  my_enum: 54321
rpcs:
  my_rpc: 67890
''';
        final fromYaml = GeneratorLockfile.fromYaml(yaml);
        expect(fromYaml, equals(lockfile));
      });
    });

    group('fromConfig', () {
      test('creates a lockfile from a generator config', () {
        const tableConfig = TableConfig(name: 'my_table', columns: []);
        const enumConfig = EnumConfig(
          enumName: 'my_enum',
          formattedEnumName: 'MyEnum',
          values: ['a', 'b'],
        );
        final rpcConfig = RpcConfig(
          functionName: 'my_rpc',
          args: const [],
          returnType: RpcReturnTypeConfig.empty(),
        );
        final config = GeneratorConfig(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: [tableConfig],
          enums: [enumConfig],
          rpcs: [rpcConfig],
        );

        final fromConfig = GeneratorLockfile.fromConfig(config);

        final expectedLockfile = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: {'my_table': tableConfig.hashCode},
          enums: {'my_enum': enumConfig.hashCode},
          rpcs: {'my_rpc': rpcConfig.hashCode},
        );

        expect(fromConfig, equals(expectedLockfile));
      });

      test('creates a lockfile equal to a previously generated lockfile', () {
        final config = GeneratorConfig.fromJson(configJson);
        final fromConfig = GeneratorLockfile.fromConfig(config);
        final fromJson = GeneratorLockfile.fromJson(lockfileJson);
        expect(fromConfig == fromJson, isTrue);
      });
    });

    group('toJson', () {
      test('converts a lockfile to json', () {
        final json = lockfile.toJson();
        final expectedJson = {
          'date': date.toString(),
          'package': package,
          'version': version,
          'forFlutter': forFlutter,
          'barrelFiles': barrelFiles,
          'tag': tag,
          'tables': tables,
          'enums': enums,
          'rpcs': rpcs,
        };
        for (final key in expectedJson.keys) {
          expect(json.containsKey(key), isTrue);
          expect(json[key], equals(expectedJson[key]));
        }
      });
    });

    group('toYaml', () {
      test('converts a lockfile to yaml', () {
        final yamlString = lockfile.toYaml();
        final decodedYaml = loadYaml(yamlString) as YamlMap;
        final expectedJson = {
          'date': date.toString(),
          'package': package,
          'version': version,
          'forFlutter': forFlutter,
          'barrelFiles': barrelFiles,
          'tag': tag,
          'tables': tables,
          'enums': enums,
          'rpcs': rpcs,
        };
        for (final key in expectedJson.keys) {
          expect(decodedYaml.containsKey(key), isTrue);
          expect(decodedYaml[key], equals(expectedJson[key]));
        }
      });
    });

    group('hashCode', () {
      test('returns a consistent hash code', () {
        final lockfile1 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: tables,
          enums: enums,
          rpcs: rpcs,
        );
        final lockfile2 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: tables,
          enums: enums,
          rpcs: rpcs,
        );
        expect(lockfile1.hashCode, equals(lockfile2.hashCode));
      });
    });

    group('== operator', () {
      test('returns true for equal objects', () {
        final lockfile1 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: tables,
          enums: enums,
          rpcs: rpcs,
        );
        final lockfile2 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: tables,
          enums: enums,
          rpcs: rpcs,
        );
        expect(lockfile1, equals(lockfile2));
      });

      test('returns false for unequal objects', () {
        final lockfile1 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: tables,
          enums: enums,
          rpcs: rpcs,
        );
        final lockfile2 = GeneratorLockfile(
          date: date,
          package: 'other_package',
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: tables,
          enums: enums,
          rpcs: rpcs,
        );
        expect(lockfile1, isNot(equals(lockfile2)));
      });
    });
  });
}
