import 'package:supabase_codegen/src/generator/generator.dart'
    show ColumnOverride;

/// Table overrides
typedef TableOverrides = Map<String, ColumnOverride>;

/// Map of table to column and the overrides for that column
/// in the generated dart class
typedef SchemaOverrides = Map<String, TableOverrides>;
