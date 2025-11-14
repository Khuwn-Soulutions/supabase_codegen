import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template supabase_schema_generator}
/// Supabase schema generator
/// {@endtemplate}
class SupabaseSchemaGenerator {
  /// {@macro supabase_schema_generator}
  const SupabaseSchemaGenerator({
    this.bundleGenerator = const BundleGenerator(),
    this.lockfileManager = const GeneratorLockfileManager(),
  });

  /// Bundle generator
  final BundleGenerator bundleGenerator;

  /// Supabase client instance.
  static late SupabaseClient client;

  /// Config
  static GeneratorConfig config = GeneratorConfig.empty();

  /// Lockfile manager
  final GeneratorLockfileManager lockfileManager;

  /// Generate schema info
  Future<bool> generateSchema([
    GeneratorConfig? genConfig,
    String? outputFolder,
  ]) async {
    config = genConfig ?? GeneratorConfig.empty();
    logger.detail('Generating with config: ${jsonEncode(config.toJson())}');

    final (:deletes, :lockfile, :upserts) = await lockfileManager
        .processLockFile(config);

    logger.detail(
      'Lockfile: ${jsonEncode(lockfile.toJson())}, '
      'upserts: $upserts, deletes: $deletes',
    );

    // Stop if no changes
    if (upserts == null && deletes == null) {
      return false;
    }

    // Output Directory
    final outputDir = Directory(outputFolder ?? root);

    // Handle upserts
    if (upserts != null) {
      await bundleGenerator.generateFiles(outputDir, upserts, config);
    }

    // Handle deletes
    if (deletes != null) {
      for (final enumFileName in deletes.enums) {
        final enumPath = path.join(outputDir.path, enumFileName);
        final file = File(enumPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }

    // Write the lockfile
    _writeLockFile(lockfile);

    return true;
  }

  /// Write the generator lockfile (to the project root)
  void _writeLockFile(GeneratorLockfile lockfile) {
    final lockFileProgress = logger.progress('Cleaning up generated files');

    lockfileManager.writeLockfile(lockfile: lockfile);

    lockFileProgress.complete('Lockfile created');
  }

  /// Create the supabase client
  SupabaseClient createClient(String supabaseUrl, String supabaseKey) {
    return client = SupabaseClient(supabaseUrl, supabaseKey);
  }
}
