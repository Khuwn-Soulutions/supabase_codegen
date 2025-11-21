import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// {@template serverpod_schema_generator}
/// Serverpod Schema Generator
/// {@endtemplate}
class ServerpodSchemaGenerator extends SupabaseSchemaGenerator {
  /// {@macro serverpod_schema_generator}
  const ServerpodSchemaGenerator()
    : super(
        bundleGenerator: const SpyBundleGenerator(),
      );

  @override
  Future<GeneratorConfig> generateConfig(GeneratorConfigParams params) async {
    final config = await super.generateConfig(params);

    // Remove serverpod tables
    return config.copyWith(
      barrelFiles: false,
      tables: config.tables
          .where((table) => !table.name.startsWith('serverpod'))
          .toList(),
    );
  }
}
