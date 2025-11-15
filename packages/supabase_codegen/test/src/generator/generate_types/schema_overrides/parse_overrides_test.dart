import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

void main() {
  group('Parse Schema Overrides', () {
    final codegenConfig = <String, dynamic>{
      'override': {
        'users': {
          'id': {'data_type': 'String', 'is_nullable': false},
          'email': {
            'data_type': 'String',
            'is_nullable': true,
            'column_default': 'test@example.com',
          },
        },
        'posts': {
          'title': {'data_type': 'String'},
        },
      },
    };

    test('extractSchemaOverrides extracts overrides correctly', () {
      final overrides = extractSchemaOverrides(codegenConfig);

      expect(overrides, isA<SchemaOverrides>());
      expect(overrides.length, 2);
      expect(overrides.containsKey('users'), isTrue);
      expect(overrides.containsKey('posts'), isTrue);

      // Verify 'users' table overrides
      final userOverrides = overrides['users'];
      expect(userOverrides, isNotNull);
      expect(userOverrides!.length, 2);
      expect(userOverrides.containsKey('id'), isTrue);
      expect(userOverrides.containsKey('email'), isTrue);

      final userIdOverride = userOverrides['id'];
      expect(userIdOverride, isNotNull);
      expect(userIdOverride!.dataType, 'String');
      expect(userIdOverride.isNullable, false);
      expect(userIdOverride.columnDefault, isNull);

      final userEmailOverride = userOverrides['email'];
      expect(userEmailOverride, isNotNull);
      expect(userEmailOverride!.dataType, 'String');
      expect(userEmailOverride.isNullable, true);
      expect(userEmailOverride.columnDefault, 'test@example.com');

      // Verify 'posts' table overrides
      final postOverrides = overrides['posts'];
      expect(postOverrides, isNotNull);
      expect(postOverrides!.length, 1);
      expect(postOverrides.containsKey('title'), isTrue);

      final titleOverride = postOverrides['title'];
      expect(titleOverride, isNotNull);
      expect(titleOverride!.dataType, 'String');
      expect(titleOverride.isNullable, isNull);
      expect(titleOverride.columnDefault, isNull);
    });
  });
}
