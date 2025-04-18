import 'package:dotenv/dotenv.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:supabase_codegen/supabase_codegen.dart' show supabaseEnvKeys;

/// Supabase client instance to generate types.
late SupabaseClient client;

/// Root directory path for generating files
late String root;

/// Tag
String tag = '';

/// Enums file name
const enumsFileName = '_enums';

/// Map of enum type to formatted name
final formattedEnums = <String, String>{};

/// Should the footer generation be skipped
bool skipFooterWrite = false;

/// Are the types being generated for Flutter usage
bool forFlutterUsage = false;

/// Column data type
typedef ColumnData = ({
  String dartType,
  bool isNullable,
  bool hasDefault,
  dynamic defaultValue,
  String columnName,
  bool isArray,
  bool isEnum,
});

/// Field name type map
typedef FieldNameTypeMap = Map<String, ColumnData>;

/// Supabase code gnerator utils class
// coverage:ignore-start
@visibleForTesting
class SupabaseCodeGeneratorUtils {
  /// Constructor
  const SupabaseCodeGeneratorUtils();

  /// Generate schema info
  @visibleForTesting
  Future<void> generateSchema() => generateSchemaInfo();

  /// Create the supabase client
  SupabaseClient createClient(String supabaseUrl, String supabaseKey) =>
      SupabaseClient(supabaseUrl, supabaseKey);
}
// coverage:ignore-end

/// Supabase code generator
class SupabaseCodeGenerator {
  /// Constructor
  const SupabaseCodeGenerator({
    this.utils = const SupabaseCodeGeneratorUtils(),
  });

  /// Utility class
  @visibleForTesting
  final SupabaseCodeGeneratorUtils utils;

  /// Generate Supabase types
  Future<void> generateSupabaseTypes({
    required String envFilePath,
    required String outputFolder,

    /// Tags to add to file footer
    String fileTag = '',

    /// Should the footer be skipped
    bool skipFooter = false,

    /// Is this for Flutter usage
    bool forFlutter = false,
  }) async {
    /// Set tag
    tag = fileTag;

    /// Set root folder
    root = outputFolder;

    /// Set skip footer
    skipFooterWrite = skipFooter;

    /// Load env keys
    final dotenv = DotEnv()..load([envFilePath]);
    final hasUrl = dotenv.isEveryDefined([supabaseEnvKeys.url]);
    if (!hasUrl) {
      throw Exception(
        '[GenerateTypes] Missing ${supabaseEnvKeys.url} in $envFilePath file. ',
      );
    }

    final supabaseKey = dotenv.getOrElse(
      supabaseEnvKeys.anonKey,
      () => dotenv[supabaseEnvKeys.key] ?? '',
    );
    if (supabaseKey.isEmpty) {
      throw Exception(
        '[GenerateTypes] Ensure that either ${supabaseEnvKeys.anonKey} '
        'or ${supabaseEnvKeys.anonKey} is set to ensure access to the database',
      );
    }

    // Get the config from env
    final supabaseUrl = dotenv[supabaseEnvKeys.url]!;
    logger.i('[GenerateTypes] Starting type generation');

    client = utils.createClient(supabaseUrl, supabaseKey);

    await utils.generateSchema();
  }
}
