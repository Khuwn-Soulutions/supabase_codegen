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

/// Map of enum type to formatted name
final formattedEnums = <String, String>{};

/// Supabase code generator
class SupabaseCodeGenerator {
  /// Constructor
  const SupabaseCodeGenerator({
    this.schemaGenerator = const SupabaseSchemaGenerator(),
  });

  /// Utility class
  @visibleForTesting
  final SupabaseSchemaGenerator schemaGenerator;

  /// Generate Supabase types
  Future<void> generateSupabaseTypes(GeneratorConfigParams params) async {
    final progress = logger.progress('Generating Supabase types...');
    try {
      /// Initialize the supabase client
      initSupabaseClient(params.envFilePath);

      final generated = await schemaGenerator.generate(params);

      /// Handle failed generation
      if (!generated) {
        progress.cancel();
        logger.alert('No changes detected. Skipping file generation');
        return;
      }

      /// Display success
      final outputFolderLink = link(
        message: params.outputFolder,
        uri: Uri.directory(
          path.join(Directory.current.path, params.outputFolder),
        ),
      );

      progress.complete(
        'Supabase types generated successfully to $outputFolderLink',
      );
    } on Exception catch (error) {
      progress.fail('Error while generating types: $error');
      rethrow;
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
    client = schemaGenerator.createClient(supabaseUrl, supabaseKey);
  }
}
