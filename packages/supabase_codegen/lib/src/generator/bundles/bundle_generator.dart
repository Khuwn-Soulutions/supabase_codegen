import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template bundle_generator}
/// Executes generation of the bundles
/// {@endtemplate}
class BundleGenerator {
  /// {@macro bundle_generator}
  const BundleGenerator();

  /// Generate files to the [outputDir]
  ///
  /// The [generated] parameter is for testing only and allows tests to
  /// inject a pre-populated or empty list to verify error handling.
  Future<List<GeneratedFile>> generateFiles(
    Directory outputDir,
    GeneratorConfig? upserts, [
    GeneratorConfig? barrelConfig,
    List<GeneratedFile>? generated,
  ]) async {
    final generatedFiles = generated ?? [];
    final progress = logger.progress('Generating Tables and Enums...');
    try {
      if (upserts != null) {
        final tablesAndEnums = await generateTablesAndEnums(outputDir, upserts);
        generatedFiles.addAll(tablesAndEnums);
        final rpcFunctions = await generateRpcFunctions(outputDir, upserts);
        generatedFiles.addAll(rpcFunctions);
      }

      // Generate barrel files
      if (barrelConfig?.barrelFiles ?? false) {
        progress.update('Generating barrel files');
        final barrelFiles = await generateBarrelFiles(outputDir, barrelConfig!);
        generatedFiles.addAll(barrelFiles);
      }
      progress.complete('Types generated successfully');

      // Run post generation clean up process
      await cleanup(outputDir, generatedFiles: generatedFiles);
    }
    // Catch all exceptions and errors
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      progress.fail('Generation failed: $e');
      rethrow;
    }

    return generatedFiles;
  }

  /// Generate tables and enums into the [outputDir] with the provided [config]
  Future<List<GeneratedFile>> generateTablesAndEnums(
    Directory outputDir,
    GeneratorConfig config,
  ) => _generateBundle(
    outputDir: outputDir,
    config: config,
    bundle: tablesAndEnumsBundle,
  );

  /// Generate RPC functions into the [outputDir] with the provided [config]
  Future<List<GeneratedFile>> generateRpcFunctions(
    Directory outputDir,
    GeneratorConfig config,
  ) => _generateBundle(
    outputDir: outputDir,
    config: config,
    bundle: rpcFunctionsBundle,
  );

  /// Generate barrel files into the [outputDir] with the provided [config]
  Future<List<GeneratedFile>> generateBarrelFiles(
    Directory outputDir,
    GeneratorConfig config,
  ) => _generateBundle(
    outputDir: outputDir,
    config: config,
    bundle: barrelFilesBundle,
  );

  /// Generate the [bundle] into the [outputDir] with the provided [config]
  Future<List<GeneratedFile>> _generateBundle({
    required Directory outputDir,
    required GeneratorConfig config,
    required MasonBundle bundle,
  }) async {
    final generator = await MasonGenerator.fromBundle(bundle);
    final target = DirectoryGeneratorTarget(outputDir);
    return generator.generate(target, vars: config.toJson());
  }

  /// Run post generation clean up process
  Future<void> cleanup(
    Directory outputDir, {
    List<GeneratedFile> generatedFiles = const [],
  }) async {
    final cleanup = logger.progress('Cleaning up generated files');

    _ensureFileExtension(outputDir);
    _formatFiles(outputDir);

    cleanup.complete('Generated files cleaned up successfully');

    for (final (index, file) in generatedFiles.indexed) {
      final filePath = _replaceMustache(file.path);
      generatedFiles[index] = file.copyWith(path: filePath);
      final fileLink = link(
        message: filePath,
        uri: Uri.file(path.join(Directory.current.path, filePath)),
      );
      logger.success('✅ ${file.status.name.toCapitalCase()}: $fileLink');
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
