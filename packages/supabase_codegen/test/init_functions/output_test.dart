import 'package:supabase_codegen/init/init_functions/output.dart';
import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

void main() {
  group('chooseOutputFolder', () {
    test('returns the default output folder', () {
      // Arrange
      final expectedOutputFolder = defaultValues[CmdOption.output] as String;
      // Act
      final result = chooseOutputFolder();
      // Assert
      expect(result, equals(expectedOutputFolder));
    });
  });
}
