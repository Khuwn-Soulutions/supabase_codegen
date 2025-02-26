import 'dart:io';

void main() async {
  /// Variable to store sql functions
  final functions = StringBuffer();

  /// SQL Directory
  final sqlDirectory = Directory('sql');

  /// Write all files in the sql directory to the buffer
  for (final file in sqlDirectory.listSync()) {
    functions
      ..write(File(file.path).readAsStringSync())
      ..writeln('\n');
  }

  /// Create new migration using supabase CLI
  final result = await Process.run(
    'supabase',
    ['migration', 'new', 'add_codegen_functions'],
    runInShell: true,
  );

  /// Read path of migration
  final path = extractPath(result.stdout.toString());
  if (path.isEmpty) return;

  /// Write the sql functions to migration file
  File(path).writeAsStringSync(functions.toString());

  // Print result to shell
  // ignore: avoid_print
  print('Migration file created at: $path');
}

/// Extract the path from the given [input]
String extractPath(String input) {
  // Define a regular expression to match the path
  final RegExp pathRegExp = RegExp(r'\b\w+/\w+/\d+_\w+\.sql\b');

  // Find the match in the input string
  final Match? match = pathRegExp.firstMatch(input);

  // If a match is found, return the matched path
  if (match != null) {
    return match.group(0)!;
  }

  // If no match is found, return an empty string or handle it as needed
  return '';
}
