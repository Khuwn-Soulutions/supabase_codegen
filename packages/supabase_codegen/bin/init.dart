import 'package:supabase_codegen/init/init.dart';
import 'package:supabase_codegen/migrations/migrations.dart';

/// Main function export
Future<void> main() async {
  await initializeConfiguration();
  await checkMigration();
}
