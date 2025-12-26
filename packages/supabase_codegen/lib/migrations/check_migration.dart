import 'dart:io';

import 'package:dcli/dcli.dart' as dcli;
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart';
import 'package:supabase_codegen/migrations/migrations.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Add codegen functions migration name
const _addFunctions = 'add_codegen_functions';

/// Update codegen functions migration name
/// Used when migration with [_addFunctions] already exists
const _updateFunctions = 'update_codegen_functions';

/// Working directory for migrations
const _migrationsDirectory = './supabase/migrations';

/// Check for migration to apply to add or update codegen functions
Future<void> checkMigration() async {
  final result = await getMigration();
  if (result == null) {
    logger.info('No migration to apply.');
    return;
  }

  final (:migration, :name) = result;
  logger.detail(dcli.green('Migration to add/update: $name'));
  await addCodegenFunctionsMigration(migration: migration, name: name);
  logger.success('Migration created please apply to your database.');
}

/// Get migration to apply to add or update codegen functions
Future<({String migration, String name})?> getMigration() async {
  final files =
      dcli
          .find(
            '*($_addFunctions|$_updateFunctions).sql',
            workingDirectory: _migrationsDirectory,
          )
          .toList()
        ..sort();
  logger
    ..detail('Found migrations:')
    ..detail(files.map(relative).join('\n'));
  final migrationName = files.isNotEmpty ? _updateFunctions : _addFunctions;
  logger.detail('Using migration name: $migrationName');

  /// Variable to store sql functions
  final allFunctions = sqlFunctions.toList();

  /// Check all migrations for changes
  for (final file in files) {
    /// Read contents of latest migration
    final contents = await File(file).readAsString();

    /// Remove functions that exist in migration from [allFunctions]
    final functions = allFunctions.toList();
    for (final function in functions) {
      if (contents.contains(function.trim())) {
        allFunctions.remove(function);
      }
    }

    // If no new functions to add, exit
    if (allFunctions.isEmpty) {
      logger.info(
        dcli.green('No function changes detected since latest migration.'),
      );
      return null;
    }
  }

  logger.info(dcli.yellow('Function changes detected since latest migration.'));

  /// The migration to add/update
  final migration = allFunctions.join('\n');

  logger.detail('Migration found to be applied: $migration');
  return (migration: migration, name: migrationName);
}

/// Add codegen functions migration
Future<void> addCodegenFunctionsMigration({
  required String migration,
  String name = _addFunctions,
}) async {
  /// Create new migration using supabase CLI
  final result = await Process.run('supabase', [
    'migration',
    'new',
    name,
  ], runInShell: true);

  /// Read path of migration
  final path = extractPath(result.stdout.toString());
  if (path.isEmpty) {
    logger
      ..err('Failed to extract migration path from CLI output.')
      ..detail('CLI stdout: ${result.stdout}')
      ..detail('CLI stderr: ${result.stderr}');
    return;
  }

  /// Write the sql functions to migration file
  path.write(migration);

  // Print result to shell
  // ignore: avoid_print
  final pathLink = link(uri: Uri.file(path), message: path);
  logger.info('Migration file created at: $pathLink');
}

/// Extract the path from the given [input]
String extractPath(String input) {
  // Define a regular expression to match the path
  final pathRegExp = RegExp(r'\b\w+/\w+/\d+_\w+\.sql\b');

  // Find the match in the input string
  final Match? match = pathRegExp.firstMatch(input);

  // If a match is found, return the matched path
  if (match != null) {
    return match.group(0)!;
  }

  // If no match is found, return an empty string or handle it as needed
  return '';
}
