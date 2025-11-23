import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// [GeneratorConfig] extension
extension GeneratorConfigExtension on GeneratorConfig {
  /// Converts this [GeneratorConfig] to a json map
  /// for use in generating Serverpod models
  Map<String, dynamic> toServerpodJson() {
    final tableJson = tables.map((table) => table.toServerpodJson()).toList();
    logger.detail('Table json: $tableJson');
    return <String, dynamic>{
      ...toJson(),
      // IMPORTANT: Must be null if no tables are to be generated
      'tables': tableJson.isEmpty ? null : tableJson,
    };
  }
}
