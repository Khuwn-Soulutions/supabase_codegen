import 'dart:io';

void main() async {
  final result = await Process.run(
    'dart',
    [
      'run',
      'supabase_codegen:add_codegen_functions',
    ],
    runInShell: true,
  );

  // Print result to shell
  // ignore: avoid_print
  print(result.stdout);
}
