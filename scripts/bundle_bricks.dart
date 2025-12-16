import 'dart:io';

import 'package:talker/talker.dart';

/// Bundle the mason bricks
void main(List<String> args) async {
  /// Templates folder
  const templatesFolder = 'packages/supabase_codegen_templates';

  // Output folder
  const outputFolder = 'packages/supabase_codegen/lib/src/generator/bundles';

  /// Bricks
  const bricks = ['tables_and_enums', 'barrel_files', 'rpc_functions'];

  await bundleBricks(
    bricks: bricks,
    templatesFolder: templatesFolder,
    outputFolder: outputFolder,
  );
}

/// Bundle the mason [bricks] into the [outputFolder] from the [templatesFolder]
Future<void> bundleBricks({
  required List<String> bricks,
  required String templatesFolder,
  required String outputFolder,
}) async {
  final logger = Talker();
  // For each brick create a bundle
  for (final brick in bricks) {
    final output = await Process.run('mason', [
      'bundle',
      '$templatesFolder/$brick',
      '--output-dir',
      outputFolder,
      '--type',
      'dart',
    ]);
    logger.info(output.stdout);

    if (output.exitCode != 0) {
      logger.error('Failed to bundle $brick brick: ${output.stderr}');
      exit(output.exitCode);
    }
  }

  // Format the generated code
  final formatOutput = await Process.run('dart', ['format', outputFolder]);
  logger.info(formatOutput.stdout);
  if (formatOutput.exitCode != 0) {
    logger.error('Failed to format output: ${formatOutput.stderr}');
    exit(formatOutput.exitCode);
  }
  logger.info('Formatted generated bricks in $outputFolder');
}
