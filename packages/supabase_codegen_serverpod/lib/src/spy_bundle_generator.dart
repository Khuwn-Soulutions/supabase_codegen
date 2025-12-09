import 'dart:io';

import 'package:mason/mason.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// Bundle Generator for Serverpod Yaml Files
class SpyBundleGenerator extends BundleGenerator {
  /// Constructor
  const SpyBundleGenerator();

  /// Generated files
  static List<GeneratedFile> generatedFiles = [];

  @override
  Future<void> generateFiles(
    Directory outputDir,
    GeneratorConfig? upserts, [
    // Unused: Serverpod generates yaml files, not barrel files
    GeneratorConfig? _,
  ]) async {
    final progress = logger.progress('Generating Spy Files...');
    if (upserts == null) return;

    await generateSpyFiles(outputDir, upserts);
    await generateRpcFunctions(outputDir, upserts);
    progress.complete();

    // Run post generation clean up process
    await cleanup(outputDir);
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
