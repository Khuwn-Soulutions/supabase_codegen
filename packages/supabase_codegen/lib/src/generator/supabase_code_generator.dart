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

/// Overrides for table and column configurations
SchemaOverrides schemaOverrides = {};

/// Supabase code generator utils class
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

    /// Overrides for table and column configurations
    SchemaOverrides overrides = const {},
  }) async {
    /// Set tag
    tag = fileTag;

    /// Set root folder
    root = outputFolder;

    /// Set skip footer
    skipFooterWrite = skipFooter;

    /// Set flutter usage
    forFlutterUsage = forFlutter;

    /// Set overrides
    schemaOverrides = overrides;

    /// Load env keys
    final dotenv = DotEnv()..load([envFilePath]);
    final hasUrl = dotenv.isEveryDefined([supabaseEnvKeys.url]);
    if (!hasUrl) {
      throw Exception(
        '[GenerateTypes] Missing ${supabaseEnvKeys.url} in $envFilePath file. ',
      );
    }

    final supabaseKey = dotenv[supabaseEnvKeys.key];
    if (supabaseKey == null || supabaseKey.isEmpty) {
      throw Exception(
        '[GenerateTypes] ${supabaseEnvKeys.key} is required to access the '
        'database schema.',
      );
    }

    // Get the config from env
    final supabaseUrl = dotenv[supabaseEnvKeys.url]!;
    logger.info('[GenerateTypes] Starting type generation');

    client = utils.createClient(supabaseUrl, supabaseKey);

    await utils.generateSchema();
  }
}
