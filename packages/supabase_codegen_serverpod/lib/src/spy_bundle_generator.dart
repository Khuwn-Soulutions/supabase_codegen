import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
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
    GeneratorConfig? barrelConfig,
  ]) async {
    final progress = logger.progress('Generating Spy Files...');
    if (upserts == null) return;

    await generateSpyFiles(
      outputDir,
      upserts.copyWith(package: 'supabase_codegen_serverpod'),
    );
    progress.complete();
    for (final file in generatedFiles) {
      final fileLink = link(
        message: file.path,
        uri: Uri.directory(path.join(Directory.current.path, file.path)),
      );
      logger.info('✅ ${file.status.name.toCapitalCase()}: $fileLink');
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
