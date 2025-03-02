import 'package:supabase_codegen/supabase_codegen.dart';

import 'supabase_client.mock.dart';

const roleField = 'role';
const emailField = 'email';

final requiredUserKeys = [emailField, roleField];

final Map<String, dynamic> userData = {
  emailField: 'john@example.com',
  'acc_name': 'John Doe',
  'phone_number': '+1234567890',
  'contacts': ['me@them.com'],
  roleField: 'admin',
  'created_at': DateTime.now(),
};

enum UserRole {
  admin,
  user,
}

/// Users Table
class UsersTable extends SupabaseTable<UsersRow> {
  /// Users Table
  UsersTable() : super(client: mockSupabase);

  /// Table Name
  @override
  String get tableName => 'users';

  /// Create a [UsersRow] from the [data] provided
  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

/// Users Row
class UsersRow extends SupabaseDataRow {
  /// Users Row
  const UsersRow(super.data);

  /// Construct Users Row using fields
  factory UsersRow.withFields({
    required String email,
    required UserRole role,
    String? accName,
    String? phoneNumber,
    List<String>? contacts,
    DateTime? createdAt,
  }) =>
      UsersRow({
        'email': email,
        'role': role.name,
        if (accName != null) 'acc_name': accName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (contacts != null) 'contacts': contacts,
        if (createdAt != null) 'created_at': createdAt,
      });

  /// Get the [SupabaseTable] for this row
  @override
  SupabaseTable get table => UsersTable();

  /// Email
  String get email => getField<String>('email')!;
  set email(String value) => setField<String>('email', value);

  /// Acc Name
  String? get accName => getField<String>('acc_name');
  set accName(String? value) => setField<String>('acc_name', value);

  /// Phone Number
  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  /// Contacts
  List<String> get contacts => getListField<String>('contacts');
  set contacts(List<String>? value) => setListField<String>('contacts', value);

  /// Created At
  DateTime get createdAt =>
      getField<DateTime>('created_at', defaultValue: DateTime.now())!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  /// Role
  UserRole get role => getField<UserRole>('role', enumValues: UserRole.values)!;
  set role(UserRole value) => setField<UserRole>('role', value);
}
