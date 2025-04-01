import 'package:supabase_codegen/src/generator/generator.dart';

import 'generated/database.dart';

/// The folder structure in the `generated` folder represents the files
/// generated for a database with a single users table.
///
/// The `main` function below depicts how the generated classes could be used
/// to perform type safe database functions
Future<void> main() async {
  final usersTable = UsersTable();

// Create new record
  final adminUser = await usersTable.insert({
    UsersRow.emailField: 'john@example.com',
    UsersRow.roleField: UserRole.admin.name,
    UsersRow.accNameField: 'John Doe',
    UsersRow.phoneNumberField: '+1234567890',
  });

// The returned object is already typed
  logger
    ..i('Email: ${adminUser.email}')
    ..i('Name: ${adminUser.accName}');

  /// Create new record with row object
  final user = UsersRow(
    email: 'user@example.com',
    role: UserRole.user,
    accName: 'Regular User',
    contacts: [
      adminUser.email,
    ],
  );

  await usersTable.insertRow(user);
}
