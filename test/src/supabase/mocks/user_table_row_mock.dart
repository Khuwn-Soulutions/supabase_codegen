import 'package:supabase_codegen/supabase_codegen.dart';

final requiredUserKeys = [UsersRow.emailField, UsersRow.roleField];

final Map<String, dynamic> userData = {
  UsersRow.idField: '1234567890',
  UsersRow.emailField: 'john@example.com',
  UsersRow.accNameField: 'John Doe',
  UsersRow.phoneNumberField: '+1234567890',
  UsersRow.contactsField: ['me@them.com'],
  UsersRow.roleField: 'admin',
  UsersRow.createdAtField: DateTime.now().toIso8601String(),
};

enum UserRole {
  admin,
  user,
}

/// Users Table
class UsersTable extends SupabaseTable<UsersRow> {
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
    String? id,
    String? accName,
    String? phoneNumber,
    List<String>? contacts,
    DateTime? createdAt,
  }) =>
      UsersRow({
        'email': email,
        'role': role.name,
        if (id != null) 'id': id,
        if (accName != null) 'acc_name': accName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (contacts != null) 'contacts': contacts,
        if (createdAt != null) 'created_at': createdAt,
      });

  /// Get the [SupabaseTable] for this row
  @override
  SupabaseTable get table => UsersTable();

  /// Id field name
  static const String idField = 'id';

  /// Id
  String get id => getField<String>(idField, defaultValue: '')!;
  set id(String value) => setField<String>(idField, value);

  /// Email field name
  static const String emailField = 'email';

  /// Email
  String get email => getField<String>(emailField)!;
  set email(String value) => setField<String>(emailField, value);

  /// Acc Name field name
  static const String accNameField = 'acc_name';

  /// Acc Name
  String? get accName => getField<String>(accNameField);
  set accName(String? value) => setField<String>(accNameField, value);

  /// Phone Number field name
  static const String phoneNumberField = 'phone_number';

  /// Phone Number
  String? get phoneNumber => getField<String>(phoneNumberField);
  set phoneNumber(String? value) => setField<String>(phoneNumberField, value);

  /// Contacts field name
  static const String contactsField = 'contacts';

  /// Contacts
  List<String> get contacts => getListField<String>(contactsField);
  set contacts(List<String>? value) =>
      setListField<String>(contactsField, value);

  /// Role field name
  static const String roleField = 'role';

  /// Role
  UserRole get role =>
      getField<UserRole>(roleField, enumValues: UserRole.values)!;
  set role(UserRole value) => setField<UserRole>(roleField, value);

  /// Created At field name
  static const String createdAtField = 'created_at';

  /// Created At
  DateTime get createdAt =>
      getField<DateTime>(createdAtField, defaultValue: DateTime.now())!;
  set createdAt(DateTime value) => setField<DateTime>(createdAtField, value);

  /// Make a copy of the current [UsersRow] overriding the provided fields
  UsersRow copyWith({
    String? email,
    UserRole? role,
    String? id,
    String? accName,
    String? phoneNumber,
    List<String>? contacts,
    DateTime? createdAt,
  }) =>
      UsersRow({
        'email': email ?? data['email'],
        'role': role?.name ?? data['role'],
        'id': id ?? data['id'],
        'acc_name': accName ?? data['acc_name'],
        'phone_number': phoneNumber ?? data['phone_number'],
        'contacts': contacts ?? data['contacts'],
        'created_at': createdAt ?? data['created_at'],
      });
}
