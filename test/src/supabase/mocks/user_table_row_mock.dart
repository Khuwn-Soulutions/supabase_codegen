import 'package:supabase_codegen/supabase_codegen.dart';

import 'supabase_client.mock.dart';

const roleField = 'role';
const emailField = 'email';

final Map<String, dynamic> userData = {
  emailField: 'john@example.com',
  'acc_name': 'John Doe',
  'phone_number': '+1234567890',
  'contacts': ['me@them.com'],
  roleField: 'admin',
};

enum Role {
  admin,
  user,
}

/// Users Table
class UsersTable extends SupabaseTable<UsersRow> {
  UsersTable() : super(client: mockSupabase);

  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

/// Users Row
class UsersRow extends SupabaseDataRow {
  const UsersRow(super.data);

  @override
  SupabaseTable get table => UsersTable();

  Role get role => getField<Role>(roleField, enumValues: Role.values)!;
  set role(Role value) => setField(roleField, value);

  String get email => getField<String>(emailField)!;
  set email(String value) => setField(emailField, value);
}
