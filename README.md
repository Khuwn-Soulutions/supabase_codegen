# Supabase Codegen

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

Supabase Codegen generates type-safe Dart models from your Supabase tables automatically!

## Installation 💻

**❗ In order to start using Supabase Codegen you must have the [Dart SDK][dart_install_link] installed on your machine.**

Add the following to your pubspec.yaml

```yaml
dependencies:
  supabase_codegen:
    git:
      url: https://github.com/jwelmac/supabase_codegen.git
      ref: main
```

---

## Continuous Integration 🤖

Supabase Codegen comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## ✨ Features

- Automatically generates Dart classes from Supabase tables
- Creates type-safe models with full IDE support
- Supports complex relationships and nested structures
- Generates getters and setters for all fields

## 📋 Prerequisites

- Supabase project with tables
- Dart/Flutter development environment
- Environment configuration file (`.env`)

## 🛠️ Setup

1. Install the package. See [Installation](#installation-)
2. Create a `.env` file at the root of your project with your Supabase credentials. See [example.env](example.env).
3. Create SQL functions in Supabase.  
   Options:
   - Copy and run the sql from [get_schema_info](bin/sql/get_schema_info.dart) and [get_enum_types](bin/sql/get_enum_types.dart) in your Supabase project.
   - Create migration to apply to your local or remote database with `dart run supabase_codegen:add_codegen_functions` and apply the migration with [`supabase migration up`](https://supabase.com/docs/reference/cli/supabase-migration-up).  
   Note: this requires [Supabase CLI](https://supabase.com/docs/reference/cli/introduction) with linked project

4. Run the generation script: `dart run supabase_codegen:generate_types`  
Options:  

- `--output` or `-o`: Folder to output generated files relative to project root. (Default: `supabase/types`)
- `--env` or `-e`: Path to env file to read Supabase credentials. (Default: `.env`)

Example:

```bash
dart run supabase_codegen:generate_types --output lib/types -e .env.production
```

## 📦 Generated Types

The generator will create strongly-typed models like this:

```dart
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
```

## 🚀 Usage Examples

### Reading Data

```dart
final usersTable = UsersTable();

// Fetch a single user
final user = await usersTable.querySingleRow(
  queryFn: (q) => q.eq('id', 123),
);

// Access typed properties
print(user.email);
print(user.accName);
print(user.phoneNumber);
print(user.createdAt);

// Fetch multiple users
final adminUsers = await usersTable.queryRows(
  queryFn: (q) => q
  .eq('role', UserRole.admin.name)
  .order('email'),
);

// Work with typed objects
for (final user in adminUsers) {
  print('User ${user.id}:');
  print('- Email: ${user.email}');
  print('- Name: ${user.accName ?? "No name set"}');
  print('- Phone: ${user.phoneNumber ?? "No phone set"}');
  print('- Created: ${user.createdAt}');
}

// Query with complex conditions
final recentUsers = await usersTable.queryRows(
  queryFn: (q) => q
  .gte('created_at', DateTime.now().subtract(Duration(days: 7)))
  .ilike('email', '%@gmail.com')
  .order('created_at', ascending: false),
);
```

### Creating Records

```dart
final usersTable = UsersTable();

// Create new record
final adminUser = await usersTable.insert({
  'email': 'john@example.com',
  'role': UserRole.user.name,
  'acc_name': 'John Doe',
  'phone_number': '+1234567890',
});

// The returned object is already typed
print(adminUser.email);
print(adminUser.accName);
```

### Updating Records

```dart
final usersTable = UsersTable();

// Update by query
await usersTable.update(
  data: {'acc_name': 'Jane Doe'},
  matchingRows: (q) => q.eq('id', 123),
);

// Update with return value
final updatedUsers = await usersTable.update(
  data: {'role': UserRole.admin.name},
  matchingRows: (q) => q.in_('id', [1, 2, 3]),
  returnRows: true,
);
```

### Deleting Records

```dart
final usersTable = UsersTable();

// Delete single record
  await usersTable.delete(
  matchingRows: (q) => q.eq('id', 123),
);

// Delete with return value
final deletedUsers = await usersTable.delete(
  matchingRows: (q) => q.eq('role', UserRole.user.name),
  returnRows: true,
);
```

### Working with Related Data

```dart
// Get a pilot and their documents
final pilotsTable = PilotsTable();
final documentsTable = DocumentsTable();

// Get pilot
final pilots = await pilotsTable.queryRows(
  queryFn: (q) => q.eq('id', pilotId),
);
final pilot = pilots.firstOrNull;

// Get related documents
if (pilot != null) {
  final documents = await documentsTable.queryRows(
    queryFn: (q) => q.eq('pilot_id', pilot.id),
  );
}
```

## 📝 Notes

- Ensure your Supabase tables have proper primary keys defined
- All generated models are null-safe
- Custom column types are supported through type converters

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the GPL-3.0 license - see the [LICENSE](LICENSE) file for details.

---

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows

## Attributions

Built using the great work by [Kennerd](https://github.com/Kemerd) at [Supabase Flutter Codegen](https://github.com/Kemerd/supabase-flutter-codegen)
