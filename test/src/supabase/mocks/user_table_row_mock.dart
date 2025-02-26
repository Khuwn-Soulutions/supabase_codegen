import 'package:supabase_codegen/supabase_codegen.dart';

import 'supabase_client.mock.dart';

const roleField = 'role';
final Map<String, dynamic> data = {
  'email': 'john@example.com',
  'acc_name': 'John Doe',
  'phone_number': '+1234567890',
  'contacts': ['me@them.com'],
  roleField: 'admin',
};

enum Role {
  admin,
  user,
}

class UsersTable extends SupabaseTable<UsersRow> {
  UsersTable() : super(client: MockSupabaseClient());

  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  const UsersRow(super.data);

  @override
  SupabaseTable get table => UsersTable();

  Role get role => getField<Role>(roleField)!;
  set role(Role value) => setField(roleField, value);
}
