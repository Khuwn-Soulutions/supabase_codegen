import 'dart:io';

import 'package:mason/mason.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template bundle_generator}
/// Executes generation of the bundles
/// {@endtemplate}
class BundleGenerator {
  /// {@macro bundle_generator}
  const BundleGenerator();

  /// Generated files
  static List<GeneratedFile> generatedFiles = [];

  /// Generate files to the [outputDir]
  Future<void> generateFiles(
    Directory outputDir,
    GeneratorConfig? upserts,
    GeneratorConfig? barrelConfig,
  ) async {
    final progress = logger.progress('Generating Tables and Enums...');
    if (upserts != null) {
      await generateTablesAndEnums(outputDir, upserts);
      await generateRpcFunctions(outputDir, upserts);
    }

    // Generate barrel files
    if (barrelConfig?.barrelFiles ?? false) {
      progress.update('Generating barrel files');
      await generateBarrelFiles(outputDir, barrelConfig!);
    }
    progress.complete('Types generated successfully');

    // Run post generation clean up process
    await _cleanup(outputDir);
  }

  /// Generate tables and enums into the [outputDir] with the provided [config]
  Future<void> generateTablesAndEnums(
    Directory outputDir,
    GeneratorConfig config,
  ) => _generateBundle(
    outputDir: outputDir,
    config: config,
    bundle: tablesAndEnumsBundle,
  );

  /// Generate RPC functions into the [outputDir] with the provided [config]
  Future<void> generateRpcFunctions(
    Directory outputDir,
    GeneratorConfig config,
  ) => _generateBundle(
    outputDir: outputDir,
    config: config,
    bundle: rpcFunctionsBundle,
  );

  /// Generate barrel files into the [outputDir] with the provided [config]
  Future<void> generateBarrelFiles(
    Directory outputDir,
    GeneratorConfig config,
  ) => _generateBundle(
    outputDir: outputDir,
    config: config,
    bundle: barrelFilesBundle,
  );

  /// Generate the [bundle] into the [outputDir] with the provided [config]
  Future<void> _generateBundle({
    required Directory outputDir,
    required GeneratorConfig config,
    required MasonBundle bundle,
  }) async {
    final generator = await MasonGenerator.fromBundle(bundle);
    final target = DirectoryGeneratorTarget(outputDir);
    final files = await generator.generate(target, vars: config.toJson());
    generatedFiles.addAll(files);
  }

  /// Run post generation clean up process
  Future<void> _cleanup(Directory outputDir) async {
    final cleanup = logger.progress('Cleaning up generated files');

    _ensureFileExtension(outputDir);
    _formatFiles(outputDir);

    cleanup.complete('Generated files cleaned up successfully');

    for (final file in generatedFiles) {
      final filePath = _replaceMustache(file.path);
      logger.success('✅ $filePath ${file.status.name}');
    }
  }

  /// Replace the mustache extension
  String _replaceMustache(String filePath) =>
      filePath.replaceAll('.mustache', '');

  /// Ensure all files in the output directory end in the proper extension
  void _ensureFileExtension(Directory outputDir) {
    final files = outputDir.listSync(recursive: true);
    for (final file in files) {
      if (file is File) {
        // rename file by removing the .mustache at the end of the file
        final newPath = _replaceMustache(file.path);

        // rename the file
        file.renameSync(newPath);
      }
    }
  }

  /// Format files
  void _formatFiles(Directory outputDir) {
    logger.detail('Running dart format');
    Process.runSync('dart', ['format', outputDir.path]);
  }
}
