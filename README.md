# Supabase Codegen

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
![Coverage Status](./coverage_badge.svg)

Supabase Codegen generates type-safe Dart models from your Supabase tables automatically!

## Installation 💻

Add the following to your pubspec.yaml

```yaml
dependencies:
  supabase_codegen: ^1.4.0
```

---

## ✨ Features

- NEW: Full support for Flutter with interoperability with [Supabase flutter](https://pub.dev/packages/supabase_flutter) package
- Automatically generates Dart classes from Supabase tables
- Creates type-safe models with full IDE support
- Supports complex relationships and nested structures
- Generates getters and setters for all fields
- Field getter fallback to non-function default values set in the database

## 📋 Prerequisites

- Supabase project with tables
- Dart/Flutter development environment

## 🛠️ Setup

1. Install the package. See [Installation](#installation-)
1. Create the SQL functions in Supabase to extract the types.  
   Options:
   - Copy and run the sql from [get_schema_info](bin/sql/get_schema_info.dart) and [get_enum_types](bin/sql/get_enum_types.dart) in your Supabase project.

   - Create migration to apply to your local or remote database with `dart run supabase_codegen:add_codegen_functions` and apply the migration with [`supabase migration up`](https://supabase.com/docs/reference/cli/supabase-migration-up).  
   Note: this requires [Supabase CLI](https://supabase.com/docs/reference/cli/introduction) with linked project

1. Create an [environment file](#environment-file) at the root of your project with your Supabase credentials.
1. Add any necessary configuration for type generation. See [Yaml configuration](#yaml-configuration).

## Environment file  

The environment file should contain the following.  
  - `SUPABASE_URL`: The API url for your Supabase instance.
  - `SUPABASE_ANON_KEY`: Anonymous key (Recommended for Flutter)  
  OR
  -  `SUPABASE_KEY`: Service Role key. (Not recommended for use in Flutter projects)

If both `SUPABASE_ANON_KEY` and `SUPABASE_KEY` are present in the environment file `SUPABASE_ANON_KEY` will be used.

## Generating types

Run the generation script by executing the following. 

```bash 
dart run supabase_codegen:generate_types
```  

### Command Line Options  

The following command-line options can be used to customize the type generation process:

- `-e, --env <env_file>` (Default: .env):

Specifies the path to the env file containing your Supabase credentials (See [example.env](example.env)).  
Example: `dart run supabase_codegen:generate_types -e .env.local`

- `-o, --output <output_folder>` (Default: supabase/types):

Sets the directory where the generated type files will be placed.  
Example: `dart run supabase_codegen:generate_types -o lib/models/supabase`

- `-t, --tag <tag>` (Default: ''):

Adds a tag to the generated files to help with versioning or distinguishing between different schemas.  
Example: `dart run supabase_codegen:generate_types -t v2`  

If set, the tag will appear at the end of the files following the file generation timestamp like this
```dart 
/// Date: 2025-03-06 15:43:24.078502
/// Tag: v2
```

- `-c, --config-yaml  <config yaml path>`       

Path to config yaml file, defaults to ".supabase_codegen.yaml".  
If not specified, reads from keys under `supabase_codegen` in `pubspec.yaml`.  
See [Yaml configuration](#yaml-configuration)

- `-d, --debug` (Default: false):

Enables debug logging to provide more verbose output during the type generation.  
Example: `dart run supabase_codegen:generate_types -d`

- `-s, --[no-]skip-footer`

Skip the writing of the footer in the generated files.
Example: `dart run supabase_codegen:generate_types --skip-footer`

- `-h, --help`
  
Show command line usage options
Example: `dart run supabase_codegen:generate_types --help`

## Yaml configuration
Instead of providing the options via the command line, you can also set them in a yaml file.
This can be either in the config yaml file (default `.supabase_codegen.yaml`) or in your `pubspec.yaml` file under the `supabase_codegen` key. 
This allows setting default values, and you only need to override them if needed from the command line.

Example config file e.g. `.supabase_codegen.yaml`
```yaml
env: .env.development # Overrides default: .env
output: lib/models/supabase # Overrides default: supabase/types
tag: v1 # Overrides default: ''
debug: true # Overrides default: false
skipFooter: true # Overrides default: false
```

Here's an example of how to configure the options in `pubspec.yaml`:

```yaml 
name: my_supabase_app
description: A sample Supabase app.

dependencies:
  supabase_codegen: ^1.4.0

flutter:
  assets:
    - env.app

supabase_codegen:
  env: env.app # Overrides default: .env
  output: lib/models/supabase # Overrides default: supabase/types
  tag: v1 # Overrides default: ''
  debug: true # Overrides default: false
  skipFooter: true # Overrides default: false
```

### Explanation (See [Command Line Options](#command-line-options)):

`env`: Sets the default path to the env file.  
`output`: Sets the default output folder.  
`tag`: Sets the default tag that will be added to the generated files.  
`debug`: Sets the default for debug logging.  
`skipFooter`: Skip the writing of the footer in the generated files.

### Priority 
The command line options have higher priority than the options defined in the yaml configuration.

*Order:*  
1. command line options   
1. configuration yaml (default: `.supabase_codegen.yaml`)  
1. pubspec.yaml (key: `supabase_codegen`)


## Client Configuration
Before accessing the [generated types](#generated-types) in your application ensure that the Supabase client is configured for use.

### Dart projects
By default, at runtime the package will look for the [environment file](environment-file) at `.env` and load the client using the credentials contained there.
If this matches your setup, no further changes are needed. 

### Using credential values

To create a client using the credential values the `createClient` function can be used as shown below.
```dart
await createClient('https://my.supabase.com...', 'my-super-safe-key');
```

### Load values from environment file

To configure the client by loading the values from an [environment file](environment-file) the `loadClientFromEnv` function should be run specifying the path to the environment file if it differs from the default.

```dart
await loadClientFromEnv();
```

#### Flutter
The default location for Flutter projects is `config.env`.
  - Note: 
    - If you are using another file. Ensure that it does not begin with `.` or it will not be loaded in Flutter. See [issue here](https://github.com/java-james/flutter_dotenv/issues/28).
    - The environment file must be added to the `assets` section of your `pubspec.yaml` file to be loaded at runtime. See [example project](example/pubspec.yaml).
    ```yaml
      flutter:
        ...
        assets:
          - config.env
    ```
    - Once loaded the client instance can be accessed at `Supabase.instance.client`.
    ```dart
    import 'package:supabase_flutter/supabase_flutter.dart';
    import 'package:supabase_codegen/supabase_codegen.dart';

    await loadClientFromEnv();
    final supabase = Supabase.instance.client;

    // Email and password sign up
    await supabase.auth.signUp(
      email: email,
      password: password,
    );
    ```

### Setting the client

A previously created SupabaseClient can be provided to the `setClient` method to set the client for use by the [generated types](#generated-types).

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

await Supabase.initialize(
  url: SUPABASE_URL,
  anonKey: SUPABASE_ANON_KEY,
);
setClient(Supabase.instance.client);
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
  UsersRow createRow(Map<String, dynamic> data) => UsersRow.fromJson(data);
}

/// Users Row
class UsersRow extends SupabaseDataRow {
  /// Users Row
  UsersRow({
    required String email,
    required UserRole role,
    String? id,
    String? accName,
    String? phoneNumber,
    List<String>? contacts,
    DateTime? createdAt,
  }) : super({
          'email': supaSerialize(email),
          'role': supaSerialize(role),
          if (id != null) 'id': supaSerialize(id),
          if (accName != null) 'acc_name': supaSerialize(accName),
          if (phoneNumber != null) 'phone_number': supaSerialize(phoneNumber),
          if (contacts != null) 'contacts': supaSerialize(contacts),
          if (createdAt != null) 'created_at': supaSerialize(createdAt),
        });

  /// Users Row
  const UsersRow._(super.data);

  /// Create Users Row from a [data] map
  factory UsersRow.fromJson(Map<String, dynamic> data) =>
      UsersRow._(data.cleaned);

  /// Get the Json representation of the row
  Map<String, dynamic> toJson() => data;

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
      getField<UserRole>(
        roleField,
        enumValues: UserRole.values,
        defaultValue: UserRole.user,
      )!;
  set role(UserRole value) => setField<UserRole>(roleField, value);

  /// Created At field name
  static const String createdAtField = 'created_at';

  /// Created At
  DateTime get createdAt =>
      getField<DateTime>(createdAtField, defaultValue: DateTime.now())!;
  set createdAt(DateTime value) => setField<DateTime>(createdAtField, value);

  /// Make a copy of the current [UsersRow]
  /// overriding the provided fields
  UsersRow copyWith({
    String? email,
    UserRole? role,
    String? id,
    String? accName,
    String? phoneNumber,
    List<String>? contacts,
    DateTime? createdAt,
  }) =>
      UsersRow.fromJson({
        'email': email ?? data['email'],
        'role': role?.name ?? data['role'],
        'id': id ?? data['id'],
        'acc_name': accName ?? data['acc_name'],
        'phone_number': phoneNumber ?? data['phone_number'],
        'contacts': contacts ?? data['contacts'],
        'created_at': createdAt ?? data['created_at'],
      });
}

```

## 🚀 Usage Examples

### Creating Records

```dart
final usersTable = UsersTable();

// Create new record
final adminUser = await usersTable.insert({
  UsersRow.emailField: 'john@example.com',
  UsersRow.roleField: UserRole.admin.name,
  UsersRow.accNameField: 'John Doe',
  UsersRow.phoneNumberField: '+1234567890',
});

// The returned object is already typed
print(adminUser.email);
print(adminUser.accName);

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
```

### Reading Data

```dart
final usersTable = UsersTable();

// Fetch a single user
final user = await usersTable.querySingleRow(
  queryFn: (q) => q.eq(UsersRow.idField, '123'),
);

// Access typed properties
print(user.email);
print(user.accName);
print(user.phoneNumber);
print(user.createdAt);

// Fetch multiple users
final adminUsers = await usersTable.queryRows(
  queryFn: (q) => q
  .eq(UsersRow.roleField, UserRole.admin.name)
  .order(UserRow.emailField),
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
  .gte(UsersRow.createdAtField, DateTime.now().subtract(Duration(days: 7)))
  .ilike(UsersRow.emailField, '%@gmail.com')
  .order(UsersRow.createdAtField, ascending: false),
);
```

### Updating Records

```dart
final usersTable = UsersTable();

// Update by query (with data)
await usersTable.update(
  data: {'acc_name': 'Jane Doe'},
  matchingRows: (q) => q.eq('id', '123'),
);

// Update with return value
final updatedUsers = await usersTable.update(
  data: {'role': UserRole.admin.name},
  matchingRows: (q) => q.in_(UsersRow.idField, ['1', '2', '3']),
  returnRows: true,
);

// Update by query (with row)
await usersTable.update(
  row: user.copyWith(
    contacts: [
      ...user.contacts,
      'some_other_user@example.com',
    ],
  ),
  matchingRows: (q) => q.eq(UsersRow.idField, user.id),
);
```

### Upserting Records

```dart
final usersTable = UsersTable();

// Upsert with data
final otherAdmin = await usersTable.upsert(
  {
    UsersRow.idField: '123',
    UsersRow.emailField: 'jane@example.com',
    UsersRow.roleField: UserRole.admin.name,
    UsersRow.accNameField: 'Jane Doe',
  },
);

// Upsert with row
final user = await usersTable.querySingleRow(
  queryFn: (q) => q.eq(UsersRow.idField, '123'),
);

final updatedUser = await usersTable.upsertRow(
  user.copyWith(role: User.admin),
  onConflict: '${UsersRow.idField}, ${UsersRow.emailField}',
);
print(updatedUser.role); // UserRole.admin
```

### Deleting Records

```dart
final usersTable = UsersTable();

// Delete single record
await usersTable.delete(
  matchingRows: (q) => q.eq(UsersRow.idField, 123),
);

// Delete with return value
final deletedUsers = await usersTable.delete(
  matchingRows: (q) => q.eq(UsersRow.roleField, UserRole.user.name),
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

## Testing
### Unit Tests

To run the unit tests, use the following command:

```bash
dart test
```

### Using mocks

To load a preconfigured mock supabase client for testing run `loadMockSupabaseClient()`  during `setUpAll` of your tests.  
The variables `mockSupabase` and `mockSupabaseHttpClient` are available for use during testing.  
See [supabase_table_test](test/src/supabase/database/supabase_table_test.dart) for an example of this in action.

For further details about these mock clients see [MockSupabaseHttpClient](https://github.com/supabase-community/mock_supabase_http_client).


## 📝 Notes

- Ensure your Supabase tables have proper primary keys defined
- All generated models are null-safe
- Custom column types are supported through type converters

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

### Continuous Integration 🤖

Supabase Codegen comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

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
