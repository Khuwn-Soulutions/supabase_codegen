import 'dart:io';

import 'package:talker/talker.dart';

/// Templates folder
const templatesFolder = 'packages/supabase_codegen_templates';

// Output folder
const outputFoler = 'packages/supabase_codegen_serverpod/lib/src/bundles';

/// Bricks
const bricks = ['serverpod'];

/// Bundle the mason bricks
void main(List<String> args) async {
  final logger = Talker();
  // For each brick create a bundle
  for (final brick in bricks) {
    final output = await Process.run('mason', [
      'bundle',
      '$templatesFolder/$brick',
      '--output-dir',
      outputFoler,
      '--type',
      'dart',
    ]);
    logger.info(output.stdout);
  }
}
