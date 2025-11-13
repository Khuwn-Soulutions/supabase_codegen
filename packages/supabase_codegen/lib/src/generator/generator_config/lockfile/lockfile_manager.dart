import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Generator lockfile manager
class GeneratorLockfileManager {
  /// Constructor
  const GeneratorLockfileManager();

  /// Lock file name
  static const lockFileName = '.supabase_codegen_lock.yaml';

  /// Get the lock file from the provided [directory]
  File _getLockFile([Directory? directory]) {
    final filePath =
        path.join(directory?.path ?? Directory.current.path, lockFileName);
    return File(filePath);
  }

  /// Get the lockfile from the [directory]
  Future<GeneratorLockfile?> getLockfile([Directory? directory]) async {
    final file = _getLockFile(directory);
    if (!file.existsSync()) {
      return null;
    }
    final content = await file.readAsString();
    if (content.isEmpty) {
      return null;
    }
    return GeneratorLockfile.fromYaml(content);
  }

  /// Write the [lockfile] to the [path]
  void writeLockfile({
    required GeneratorLockfile lockfile,
    Directory? directory,
  }) {
    final file = _getLockFile(directory);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(lockfile.toYaml());
  }
}
