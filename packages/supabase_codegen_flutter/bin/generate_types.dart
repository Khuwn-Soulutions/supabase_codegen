import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Main function
void main(List<String> args) async {
  await runGenerateTypes(
    args,
    package: 'supabase_codegen_flutter',
    forFlutter: true,
  );
}
