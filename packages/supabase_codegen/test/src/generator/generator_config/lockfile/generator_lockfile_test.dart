import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

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

    final lockfile = GeneratorLockfile(
      date: date,
      package: package,
      version: version,
      forFlutter: forFlutter,
      tag: tag,
      barrelFiles: barrelFiles,
      tables: tables,
      enums: enums,
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
        final config = GeneratorConfig(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
          tables: [tableConfig],
          enums: [enumConfig],
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
        );

        expect(fromConfig, equals(expectedLockfile));
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
        );
        expect(lockfile1, isNot(equals(lockfile2)));
      });
    });
  });
}
