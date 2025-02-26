import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';

void main() {
  group('generateSupabaseTypes', () {
    test('it throws an error when env file not found', () {
      expect(
        generateSupabaseTypes(
          envFilePath: '.no-env',
          outputFolder: '',
        ),
        throwsException,
      );
    });
  });
}
