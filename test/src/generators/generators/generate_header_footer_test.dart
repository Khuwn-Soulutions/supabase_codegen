import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

void main() {
  group('writeHeader and writeFooter', () {
    test('writeHeader writes correct header', () {
      final buffer = StringBuffer();
      writeHeader(buffer);
      expect(buffer.toString(), contains('//'));
      expect(buffer.toString(), contains('Generated file. Do not edit.'));
      expect(buffer.toString(), contains('Generated by supabase_codegen'));
      expect(buffer.toString(), contains(version));
      expect(
        buffer.toString(),
        contains('// ignore_for_file: require_trailing_commas, '
            'constant_identifier_names'),
      );
    });

    group('writeFooter writes', () {
      test('correct footer with tag', () {
        final buffer = StringBuffer();
        tag = 'test_tag';
        writeFooter(buffer);
        expect(buffer.toString(), contains('Tag: test_tag'));
      });

      test('correct footer without tag', () {
        final buffer = StringBuffer();
        tag = '';
        writeFooter(buffer);
        expect(buffer.toString(), isNot(contains('Tag:')));
      });

      test('no footer when skipFooter is true', () {
        final buffer = StringBuffer();
        skipFooterWrite = true;
        writeFooter(buffer);
        expect(buffer.toString(), isEmpty);
      });
    });
  });
}
