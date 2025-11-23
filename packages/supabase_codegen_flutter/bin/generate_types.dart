import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'init.dart';

/// Main function
void main(List<String> args) async {
  await runGenerateTypes(
    args,
    config: GeneratorConfigParams.empty().copyWith(
      package: 'supabase_codegen_flutter',
      forFlutter: true,
      outputFolder: defaultOutputPath,
    ),
  );
}
