import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

void main() {
  group('Dart type String extension', () {
    const dynamic = 'dynamic';
    const notDynamic = 'notDynamic';

    test('isDynamic returns true for "dynamic"', () {
      expect(dynamic.isDynamic, isTrue);
      expect(notDynamic.isDynamic, isFalse);
    });

    test('isNotDynamic returns false for "dynamic"', () {
      expect(dynamic.isNotDynamic, isFalse);
      expect(notDynamic.isNotDynamic, isTrue);
    });
  });
}
