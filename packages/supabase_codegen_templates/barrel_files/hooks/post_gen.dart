import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) {
  /// List the files in the current directory
  final files = Directory.current.listSync(recursive: true);
  final renameProgres = context.logger.progress('Renaming files');
  for (final file in files) {
    if (file is File) {
      // rename file by removing the .mustache at the end of the file
      final newPath = file.path.replaceAll('.mustache', '');

      // rename the file
      file.renameSync(newPath);
    }
  }
  renameProgres.complete();

  // Run dart format
  final formatProgres = context.logger.progress('Running dart format');
  Process.runSync('dart', ['format', '.']);
  formatProgres.complete();

  // Run dart fix
  final fixProgress = context.logger.progress('Running dart fix');
  Process.runSync('dart', ['fix', '.', '--apply']);
  fixProgress.complete();
}
