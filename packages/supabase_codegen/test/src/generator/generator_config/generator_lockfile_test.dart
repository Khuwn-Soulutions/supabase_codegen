import 'package:supabase_codegen/supabase_codegen_generator.dart'
    show GeneratorLockfile;
import 'package:test/test.dart';

void main() {
  group('GeneratorLockfile', () {
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

    test('given the same values has the same hashcode', () {
      final date = DateTime.now();
      const package = 'test-package';
      const version = '1.0.0';
      const forFlutter = true;
      const tag = 'test';
      const barrelFiles = true;

      final lockfile1 = GeneratorLockfile(
        date: date,
        package: package,
        version: version,
        forFlutter: forFlutter,
        tag: tag,
        barrelFiles: barrelFiles,
      );
      final lockfile2 = GeneratorLockfile(
        date: date,
        package: package,
        version: version,
        forFlutter: forFlutter,
        tag: tag,
        barrelFiles: barrelFiles,
      );

      expect(lockfile1.hashCode, equals(lockfile2.hashCode));
    });
  });
}
