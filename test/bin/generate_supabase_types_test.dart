import 'package:test/test.dart';

import '../../bin/src/generate_supabase_types.dart';

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
