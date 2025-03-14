import 'package:test/test.dart';

import '../../../../bin/src/src.dart';

void main() {
  group('writeHeader and writeFooter', () {
    test('writeHeader writes correct header', () {
      final buffer = StringBuffer();
      writeHeader(buffer);
      expect(buffer.toString(), contains('//'));
      expect(buffer.toString(), contains('Generated file. Do not edit.'));
    });

    group('writeFooter writes', () {
      test('correct footer with tag', () {
        final buffer = StringBuffer();
        tag = 'test_tag';
        writeFooter(buffer);
        expect(buffer.toString(), contains('Generated by supabase_codegen'));
        expect(buffer.toString(), contains('Tag: test_tag'));
        expect(buffer.toString(), contains(version));
      });

      test('correct footer without tag', () {
        final buffer = StringBuffer();
        tag = '';
        writeFooter(buffer);
        expect(buffer.toString(), contains('Generated by supabase_codegen'));
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
