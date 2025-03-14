import '../src.dart';

/// Write the file header
void writeHeader(StringBuffer buffer) {
  buffer
    ..writeln('//')
    ..writeln('//  Generated file. Do not edit.')
    ..writeln('//')
    ..writeln();
}

/// Write the file footer
void writeFooter(StringBuffer buffer) {
  if (skipFooterWrite) return;

  buffer
    ..writeln('/// Generated by supabase_codegen ($version)')
    ..writeln('/// Date: ${DateTime.now()}');

  // Write tag
  if (tag.isNotEmpty) {
    buffer.writeln('/// Tag: $tag');
  }
}
