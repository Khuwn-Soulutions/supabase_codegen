import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

void main() {
  group('generateSupabaseTypes', () {
    const generator = SupabaseCodeGenerator();
    test('it throws an error when env file not found', () {
      expect(
        generator.generateSupabaseTypes(
          envFilePath: '.no-env',
          outputFolder: '',
        ),
        throwsException,
      );
    });
  });
}
