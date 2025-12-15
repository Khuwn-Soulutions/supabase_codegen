import 'dart:io';

import 'package:mason/mason.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// Bundle Generator for Serverpod Yaml Files
class SpyBundleGenerator extends BundleGenerator {
  /// Constructor
  const SpyBundleGenerator();

  @override
  Future<List<GeneratedFile>> generateFiles(
    Directory outputDir,
    GeneratorConfig? upserts, [
    // Unused: Serverpod generates yaml files, not barrel files
    GeneratorConfig? _,
    List<GeneratedFile>? generated,
  ]) async {
    final generatedFiles = generated ?? [];
    final progress = logger.progress('Generating Spy Files...');
    if (upserts == null) {
      progress.fail('No upserts config provided. Skipping Spy file generation');
      return generatedFiles;
    }

    try {
      final spyFiles = await generateSpyFiles(outputDir, upserts);
      generatedFiles.addAll(spyFiles);
      final rpcFiles = await generateRpcFunctions(outputDir, upserts);
      generatedFiles.addAll(rpcFiles);

      // Run post generation clean up process
      await cleanup(outputDir, generatedFiles: generatedFiles);
      progress.complete();
    }
    // Catch all exceptions and errors
    catch (e) {
      progress.fail('Generation failed: $e');
      rethrow;
    }

    return generatedFiles;
  }

  /// Generate the spy.yaml files for the models provided
  Future<List<GeneratedFile>> generateSpyFiles(
    Directory outputDir,
    GeneratorConfig config,
  ) async {
    final generator = await MasonGenerator.fromBundle(serverpodBundle);
    final target = DirectoryGeneratorTarget(outputDir);
    final serverpodJson = config.toServerpodJson();
    logger.detail('Serverpod Json: $serverpodJson');
    return generator.generate(
      target,
      vars: serverpodJson,
    );
  }
}
