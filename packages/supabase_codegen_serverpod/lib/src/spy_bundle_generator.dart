import 'dart:io';

import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// Bundle Generator for Serverpod Yaml Files
class SpyBundleGenerator extends BundleGenerator {
  /// Constructor
  const SpyBundleGenerator();

  /// Generated files
  @visibleForTesting
  static List<GeneratedFile> generatedFiles = [];

  @override
  Future<void> generateFiles(
    Directory outputDir,
    GeneratorConfig? upserts, [
    // Unused: Serverpod generates yaml files, not barrel files
    GeneratorConfig? _,
    List<GeneratedFile>? generated,
  ]) async {
    final progress = logger.progress('Generating Spy Files...');
    if (upserts == null) {
      progress.fail('No upserts config provided. Skipping Spy file generation');
      return;
    }

    try {
      await generateSpyFiles(outputDir, upserts);
      await generateRpcFunctions(outputDir, upserts);

      // Run post generation clean up process
      await cleanup(outputDir);
      progress.complete();
    }
    // Catch all exceptions and errors
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      progress.fail('Generation failed: $e');
    }
  }

  /// Generate the spy.yaml files for the models provided
  Future<void> generateSpyFiles(
    Directory outputDir,
    GeneratorConfig config,
  ) async {
    final generator = await MasonGenerator.fromBundle(serverpodBundle);
    final target = DirectoryGeneratorTarget(outputDir);
    final serverpodJson = config.toServerpodJson();
    logger.detail('Serverpod Json: $serverpodJson');
    final files = await generator.generate(
      target,
      vars: serverpodJson,
    );
    generatedFiles.addAll(files);
  }
}
