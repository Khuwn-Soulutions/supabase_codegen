import 'dart:io';

import 'package:mason/mason.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

import 'generated/database.dart';

/// Example of generated classes usage
Future<void> main() async {
  final logger = Logger()..info('Loading mock supabase client');

  // Testing usage
  // ignore: invalid_use_of_visible_for_testing_member
  loadMockSupabaseClient();

  final usersTable = UsersTable();

  logger.info('Creating user...');

  /// Create new record
  final adminUser = await usersTable.insert({
    UsersRow.emailField: 'john@example.com',
    UsersRow.roleField: UserRole.admin.name,
    UsersRow.accNameField: 'John Doe',
    UsersRow.phoneNumberField: '+1234567890',
  });

  /// The returned object is already typed
  logger
    ..info('User email:${adminUser.email}')
    ..info('User name: ${adminUser.accName ?? ''}');

  /// Create new record with row object
  final user = UsersRow(
    email: 'user@example.com',
    role: UserRole.user,
    accName: 'Regular User',
    contacts: [adminUser.email],
  );

  await usersTable.insertRow(user);

  /// Get all users
  final users = await usersTable.queryRows();

  logger.info('Users: $users');
  exit(0);
}
