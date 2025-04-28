import 'package:supabase_codegen/init/init_functions/get_tag.dart';
import 'package:test/test.dart';

void main() {
  group('getTag', () {
    test('returns an empty string when addTag is false', () {
      final result = getTag();
      expect(result, equals(''));
    });

    test('returns the provided tag when addTag is true', () {
      // Arrange
      const addTag = true;
      const tag = 'my_tag';

      // Act
      final result = getTag(addTag: addTag, tag: tag);

      // Assert
      expect(result, equals(tag));
    });

    test('returns an empty tag if no tag is provided', () {
      // Arrange
      const addTag = true;

      // Act
      final result = getTag(addTag: addTag);

      // Assert
      expect(result, equals(''));
    });
  });
}
