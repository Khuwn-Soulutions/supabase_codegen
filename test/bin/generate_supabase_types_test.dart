import 'package:test/test.dart';

import '../../bin/src/generate_supabase_types.dart';

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
