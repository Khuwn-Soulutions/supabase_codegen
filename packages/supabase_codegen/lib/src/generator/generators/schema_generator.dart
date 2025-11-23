import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
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

  /// Config
  static GeneratorConfig config = GeneratorConfig.empty();

  /// Lockfile manager
  final GeneratorLockfileManager lockfileManager;

  /// Generate the schema files
  Future<bool> generate(GeneratorConfigParams params) async {
    config = await generateConfig(params);
    return generateSchema(params.outputFolder);
  }

  /// Generate configuration for file generation
  Future<GeneratorConfig> generateConfig(GeneratorConfigParams params) async {
    /// Get the enum config
    final enums = await generateEnumConfigs();

    /// Get the table config
    final tables = await generateTableConfigs(overrides: params.overrides);

    final config = GeneratorConfig.fromParams(
      params: params,
      tables: tables,
      enums: enums,
    );
    return config;
  }

  /// Generate schema info
  Future<bool> generateSchema(String outputFolder) async {
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
    final outputDir = Directory(outputFolder);

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
          logger.err('❌ Deleted ${file.path}');
        }
      }
    }

    // Write the lockfile
    writeLockFile(lockfile);

    return true;
  }

  /// Write the generator lockfile (to the project root)
  @visibleForTesting
  void writeLockFile(GeneratorLockfile lockfile) {
    final lockFileProgress = logger.progress('Cleaning up generated files');

    try {
      lockfileManager.writeLockfile(lockfile: lockfile);

      lockFileProgress.complete('Lockfile created');
    } on Exception catch (e) {
      lockFileProgress.fail(e.toString());
    }
  }

  /// Create the supabase client
  // coverage:ignore-start
  SupabaseClient createClient(String supabaseUrl, String supabaseKey) =>
      SupabaseClient(supabaseUrl, supabaseKey);
  // coverage:ignore-end
}
