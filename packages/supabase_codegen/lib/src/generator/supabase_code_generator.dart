import 'dart:convert';
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

/// Supabase code generator utils class
// coverage:ignore-start
class SupabaseCodeGeneratorUtils {
  /// Constructor
  const SupabaseCodeGeneratorUtils({
    this.bundleGenerator = const BundleGenerator(),
  });

  /// Bundle generator
  final BundleGenerator bundleGenerator;

  /// Supabase client instance.
  static late SupabaseClient client;

  /// Config
  static GeneratorConfig config = GeneratorConfig.empty();

  /// Lockfile manager
  static const GeneratorLockfileManager lockfileManager =
      GeneratorLockfileManager();

  /// Generated files
  static List<GeneratedFile> generatedFiles = [];

  /// Generate schema info
  @visibleForTesting
  Future<bool> generateSchema([
    GeneratorConfig? genConfig,
    String? outputFolder,
  ]) async {
    config = genConfig ?? GeneratorConfig.empty();
    logger.detail('Generating with config: ${jsonEncode(config.toJson())}');

    final (:deletes, :lockfile, :upserts) = await lockfileManager
        .processLockFile(config);

    logger.detail(
      'Lockfile: ${jsonEncode(lockfile.toJson())}, '
      'upserts: $upserts, deletes: $deletes',
    );

    // Stop if no changes
    if (upserts == null && deletes == null) {
      return false;
    }

    // Output Directory
    final outputDir = Directory(outputFolder ?? root);

    // Handle upserts
    if (upserts != null) {
      // Generate tables and enums
      await bundleGenerator.generateFiles(outputDir, upserts, config);
    }

    // Handle deletes
    if (deletes != null) {
      for (final enumFileName in deletes.enums) {
        final enumPath = path.join(outputDir.path, enumFileName);
        final file = File(enumPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }

    // Write the lockfile
    _writeLockFile(lockfile);

    return true;
  }

  /// Write the generator lockfile (to the project root)
  void _writeLockFile(GeneratorLockfile lockfile) {
    final lockFileProgress = logger.progress('Cleaning up generated files');

    lockfileManager.writeLockfile(lockfile: lockfile);

    lockFileProgress.complete('Lockfile created');
  }

  /// Create the supabase client
  SupabaseClient createClient(String supabaseUrl, String supabaseKey) {
    return client = SupabaseClient(supabaseUrl, supabaseKey);
  }
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
