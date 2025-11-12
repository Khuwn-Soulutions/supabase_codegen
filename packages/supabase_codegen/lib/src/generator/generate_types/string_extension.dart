import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// String extensions
extension GeneratorStringExtensions on String {
  /// Is this a dynamic type
  bool get isDynamic => this == DartType.dynamic;

  /// Is this not a dynamic type
  bool get isNotDynamic => !isDynamic;
}
