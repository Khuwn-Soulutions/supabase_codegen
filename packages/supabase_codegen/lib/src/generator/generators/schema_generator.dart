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

    /// Get the RPC config
    final rpcs = await generateRpcConfigs(tables: tables);

    final config = GeneratorConfig.fromParams(
      params: params,
      tables: tables,
      enums: enums,
      rpcs: rpcs,
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

    // Parse barrel file config
    final barrelConfig = config.barrelFiles
        ? parseBarrelFileConfig(
            config: config,
            upserts: upserts,
            deletes: deletes,
          )
        : null;

    // Generate files
    await bundleGenerator.generateFiles(outputDir, upserts, barrelConfig);

    // Handle deletes
    if (deletes != null) {
      for (final deletedFile in deletes) {
        final filePath = path.join(outputDir.path, deletedFile);
        final file = File(filePath);
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

  /// Parse barrel file config
  GeneratorConfig? parseBarrelFileConfig({
    required GeneratorConfig config,
    GeneratorConfig? upserts,
    List<String>? deletes,
  }) {
    final upsertedConfig = upserts ?? GeneratorConfig.empty();
    final deletedFiles = deletes ?? <String>[];

    // Identify what has been upserted
    final tablesModified = upsertedConfig.tables.isNotEmpty;
    final rpcsModified = upsertedConfig.rpcs.isNotEmpty;
    final enumsModified = upsertedConfig.enums.isNotEmpty;

    // Determine if there are no upserts or deletes
    final noUpserts = !tablesModified && !rpcsModified && !enumsModified;
    final noDeletes = deletedFiles.isEmpty;

    // Stop if no changes
    if (noUpserts && noDeletes) return null;

    // Identify if a file was deleted in a folder
    bool deleteInFolder(String folder) {
      return deletedFiles.any((file) => file.startsWith(folder));
    }

    final modified = (
      tables: tablesModified || deleteInFolder(tablesFolder),
      rpcs: rpcsModified || deleteInFolder(rpcsFolder),
      enums: enumsModified || deleteInFolder(enumsFolder),
    );

    // Stop if no modifications detected
    if (!modified.tables && !modified.rpcs && !modified.enums) {
      return null;
    }

    // Filter the config to include tables, rpcs and enums
    // if they were modified
    return config.copyWith(
      tables: modified.tables ? null : <TableConfig>[],
      rpcs: modified.rpcs ? null : <RpcConfig>[],
      enums: modified.enums ? null : <EnumConfig>[],
    );
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
