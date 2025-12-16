import 'bundle_bricks.dart';

/// Bundle the mason bricks
void main(List<String> args) async {
  /// Templates folder
  const templatesFolder = 'packages/supabase_codegen_templates';

  // Output folder
  const outputFolder = 'packages/supabase_codegen_serverpod/lib/src/bundles';

  /// Bricks
  const bricks = ['serverpod'];

  // Bundle bricks
  await bundleBricks(
    bricks: bricks,
    templatesFolder: templatesFolder,
    outputFolder: outputFolder,
  );
}
