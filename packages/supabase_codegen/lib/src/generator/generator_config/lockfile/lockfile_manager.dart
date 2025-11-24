import 'dart:convert';
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
    final filePath = path.join(
      directory?.path ?? Directory.current.path,
      lockFileName,
    );
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

  /// Process lockfile
  Future<
    ({
      GeneratorConfig? upserts,
      ({List<String> tables, List<String> enums})? deletes,
      GeneratorLockfile lockfile,
    })
  >
  processLockFile(GeneratorConfig config, {Directory? directory}) async {
    final previousLockFile = await getLockfile(directory);
    final currentLockFile = GeneratorLockfile.fromConfig(config);
    logger
      ..detail('Previous lockfile: ${jsonEncode(previousLockFile?.toJson())}')
      ..detail('Current lockfile: ${jsonEncode(currentLockFile.toJson())}');

    // First-time generation — send full config
    if (previousLockFile == null) {
      return (upserts: config, deletes: null, lockfile: currentLockFile);
    }

    // Nothing changed
    if (previousLockFile == currentLockFile) {
      return (upserts: null, deletes: null, lockfile: currentLockFile);
    }

    // Non data field changes (regenerate everything)
    if (previousLockFile.withoutData() != currentLockFile.withoutData()) {
      logger.detail('Lockfile metadata changed');
      return (upserts: config, deletes: null, lockfile: currentLockFile);
    }

    // --- Lockfile changed ---
    logger.detail('Data changed, diffing data');

    // Identify deleted tables/enums
    final deletedTables = previousLockFile.tables.keys
        .where((t) => !currentLockFile.tables.containsKey(t))
        .toList();

    final deletedEnums = previousLockFile.enums.keys
        .where((e) => !currentLockFile.enums.containsKey(e))
        .toList();

    final deletedRpcs = previousLockFile.rpcs.keys
        .where((r) => !currentLockFile.rpcs.containsKey(r))
        .toList();

    // Identify upserted (added or changed) tables/enums
    final upsertTableNames = currentLockFile.tables.keys
        .where((t) => previousLockFile.tables[t] != currentLockFile.tables[t])
        .toList();

    final upsertEnumNames = currentLockFile.enums.keys
        .where((e) => previousLockFile.enums[e] != currentLockFile.enums[e])
        .toList();

    final upsertRpcNames = currentLockFile.rpcs.keys
        .where((r) => previousLockFile.rpcs[r] != currentLockFile.rpcs[r])
        .toList();

    // Build filtered GeneratorConfigs
    final upserts =
        (upsertTableNames.isEmpty &&
            upsertEnumNames.isEmpty &&
            upsertRpcNames.isEmpty)
        ? null
        : config.copyWith(
            tables: config.tables
                .where((t) => upsertTableNames.contains(t.name))
                .toList(),
            enums: config.enums
                .where((e) => upsertEnumNames.contains(e.fileName))
                .toList(),
            rpcs: config.rpcs
                .where((r) => upsertRpcNames.contains(r.functionName))
                .toList(),
          );

    final deletes =
        (deletedTables.isEmpty && deletedEnums.isEmpty && deletedRpcs.isEmpty)
        ? null
        : (tables: deletedTables, enums: deletedEnums);

    return (upserts: upserts, deletes: deletes, lockfile: currentLockFile);
  }
}
