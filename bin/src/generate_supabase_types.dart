import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

import 'src.dart';

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
  final hasKeys = dotenv.isEveryDefined(['SUPABASE_URL', 'SUPABASE_ANON_KEY']);
  if (!hasKeys) {
    throw Exception(
      '[GenerateTypes] Missing Supabase keys in $envFilePath file',
    );
  }

  // Get the config from env
  final supabaseUrl = dotenv['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv['SUPABASE_ANON_KEY']!;
  logger.i('[GenerateTypes] Starting type generation');

  client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  await generateSchemaInfo();
}
