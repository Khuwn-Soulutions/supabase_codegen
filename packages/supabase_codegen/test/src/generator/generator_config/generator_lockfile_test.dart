import 'package:supabase_codegen/supabase_codegen_generator.dart'
    show EnumConfig, GeneratorLockfile, TableConfig;
import 'package:test/test.dart';

void main() {
  group('GeneratorLockfile', () {
    final date = DateTime.now();
    const package = 'test-package';
    const version = '1.0.0';
    const forFlutter = true;
    const tag = 'test';
    const barrelFiles = true;

    test('can be created', () {
      final lockfile = GeneratorLockfile(
        date: DateTime.now(),
        package: 'test_package',
        version: '1.0.0',
        forFlutter: true,
        tag: 'test',
        barrelFiles: true,
      );
      expect(lockfile, isA<GeneratorLockfile>());
    });

    group('given the same values, the lockcodes', () {
      late GeneratorLockfile lockfile1;
      late GeneratorLockfile lockfile2;

      setUp(() {
        lockfile1 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
        );
        lockfile2 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
        );
      });

      test('have the same hashcode', () {
        expect(lockfile1.hashCode, equals(lockfile2.hashCode));
      });

      test('are equal', () {
        expect(lockfile1, equals(lockfile2));
      });
    });

    group('given different values', () {
      late GeneratorLockfile lockfile1;
      late GeneratorLockfile lockfile2;

      setUp(() {
        lockfile1 = GeneratorLockfile(
          date: date,
          package: package,
          version: version,
          forFlutter: forFlutter,
          tag: tag,
          barrelFiles: barrelFiles,
        );
      });

      final changes = [
        (field: 'date', value: DateTime.now().toString(), equal: true),
        (field: 'package', value: 'different_package', equal: false),
        (field: 'version', value: '2.0.0', equal: false),
        (field: 'forFlutter', value: !forFlutter, equal: false),
        (field: 'tag', value: 'different_tag', equal: false),
        (field: 'barrelFiles', value: !barrelFiles, equal: false),
        (
          field: 'tables',
          value: {'table1': TableConfig.empty().hashCode},
          equal: false,
        ),
        (
          field: 'enums',
          value: {'enum1': EnumConfig.empty().hashCode},
          equal: false,
        ),
      ];

      for (final (:field, :value, :equal) in changes) {
        test(
          'when the $field changes the lockfiles have different hashcodes',
          () {
            lockfile2 = GeneratorLockfile.fromJson({
              ...lockfile1.toJson(),
              field: value,
            });
            expect(lockfile1.hashCode, isNot(equals(lockfile2.hashCode)));
          },
        );
        test('when the $field changes the lockfiles equality is $equal', () {
          expect(lockfile1 == lockfile2, equals(equal));
        });
      }
    });
  });
}
