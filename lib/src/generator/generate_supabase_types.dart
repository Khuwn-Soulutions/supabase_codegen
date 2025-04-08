import 'package:dotenv/dotenv.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

import 'package:supabase_codegen/src/generator/generator.dart';

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

/// Column data type
typedef ColumnData = ({
  String dartType,
  bool isNullable,
  bool hasDefault,
  String columnName,
  bool isArray,
  bool isEnum,
});

/// Field name type map
typedef FieldNameTypeMap = Map<String, ColumnData>;

/// Env Keys
const envKeys = (
  url: 'SUPABASE_URL',
  key: 'SUPABASE_KEY',
  anonKey: 'SUPABASE_ANON_KEY',
);

/// Supabase code gnerator utils class
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
  }) async {
    /// Set tag
    tag = fileTag;

    /// Set root folder
    root = outputFolder;

    /// Set skip footer
    skipFooterWrite = skipFooter;

    /// Load env keys
    final dotenv = DotEnv()..load([envFilePath]);
    final hasUrl = dotenv.isEveryDefined([envKeys.url]);
    if (!hasUrl) {
      throw Exception(
        '[GenerateTypes] Missing ${envKeys.url} in $envFilePath file. ',
      );
    }

    final supabaseKey = dotenv.getOrElse(
      envKeys.anonKey,
      () => dotenv[envKeys.key] ?? '',
    );
    if (supabaseKey.isEmpty) {
      throw Exception(
        '[GenerateTypes] Ensure that either ${envKeys.anonKey} '
        'or ${envKeys.anonKey} is set to ensure access to the database',
      );
    }

    // Get the config from env
    final supabaseUrl = dotenv[envKeys.url]!;
    logger.i('[GenerateTypes] Starting type generation');

    client = utils.createClient(supabaseUrl, supabaseKey);

    await utils.generateSchema();
  }
}
