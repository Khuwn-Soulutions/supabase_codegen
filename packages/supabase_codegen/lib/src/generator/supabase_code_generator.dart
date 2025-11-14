import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen.dart' show supabaseEnvKeys;
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Supabase client instance to generate types.
late SupabaseClient client;

/// Root directory path for generating files
late String root;

/// Tag
String tag = '';

/// Enums file name
const enumBarrelFileName = '_enums';

/// Map of enum type to formatted name
final formattedEnums = <String, String>{};

/// Should the footer generation be skipped
bool skipFooterWrite = false;

/// Are the types being generated for Flutter usage
bool forFlutterUsage = false;

/// Package code is being generated from
const defaultPackageName = 'supabase_codegen';

/// Package code is being generated from
String packageName = defaultPackageName;

/// Overrides for table and column configurations
SchemaOverrides schemaOverrides = {};

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

    /// Should barrel files be generated
    bool barrelFiles = true,

    /// Package name
    String package = defaultPackageName,

    /// Tags to add to file footer
    String fileTag = '',

    /// Should the footer be skipped
    bool skipFooter = false,

    /// Is this for Flutter usage
    bool forFlutter = false,

    /// Overrides for table and column configurations
    SchemaOverrides overrides = const {},
  }) async {
    final progress = logger.progress('Generating Supabase types...');
    try {
      /// Initialize the supabase client
      initSupabaseClient(envFilePath);

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

      /// Get the enum config
      final enums = await generateEnumConfigs();

      /// Get the table config
      final tables = await generateTableConfigs(overrides);

      final config = GeneratorConfig(
        package: package,
        version: version,
        forFlutter: forFlutter,
        tag: tag,
        barrelFiles: barrelFiles,
        tables: tables,
        enums: enums,
      );

      final generated = await utils.generateSchema(config);

      /// Handle failed generation
      if (!generated) {
        progress.cancel();
        logger.alert('No changes detected. Skipping file generation');
        return;
      }

      /// Display success
      final outputFolderLink = link(
        message: outputFolder,
        uri: Uri.directory(path.join(Directory.current.path, outputFolder)),
      );

      progress.complete(
        'Supabase types generated successfully to $outputFolderLink',
      );
    } on Exception catch (error) {
      progress.fail('Error while generating types: $error');
      rethrow;
    } finally {
      await client.dispose();
    }
  }

  /// Initialize the supabase client
  void initSupabaseClient(String envFilePath) {
    /// Load env keys
    final dotenv = DotEnv()..load([envFilePath]);
    final hasUrl = dotenv.isEveryDefined([supabaseEnvKeys.url]);
    if (!hasUrl) {
      throw Exception('Missing ${supabaseEnvKeys.url} in $envFilePath file. ');
    }

    final supabaseKey = dotenv[supabaseEnvKeys.key];
    if (supabaseKey == null || supabaseKey.isEmpty) {
      throw Exception(
        '${supabaseEnvKeys.key} is required to access the '
        'database schema.',
      );
    }

    // Get the config from env
    final supabaseUrl = dotenv[supabaseEnvKeys.url]!;
    client = utils.createClient(supabaseUrl, supabaseKey);
  }
}
