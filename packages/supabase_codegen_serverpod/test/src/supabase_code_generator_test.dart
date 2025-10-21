import 'package:supabase_codegen_serverpod/src/codegen_utils.dart';
import 'package:supabase_codegen_serverpod/src/supabase_code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('ServerpodCodeGenerator', () {
    test('can be instantiated', () {
      expect(const ServerpodCodeGenerator(), isNotNull);
    });

    test('utils is of type SupabaseCodeGenServerpodUtils', () {
      const generator = ServerpodCodeGenerator();
      expect(
        generator.utils,
        isA<SupabaseCodeGenServerpodUtils>(),
      );
    });
  });
}
