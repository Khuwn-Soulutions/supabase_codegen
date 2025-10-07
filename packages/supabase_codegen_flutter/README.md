# Supabase Codegen Flutter

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Supabase Codegen Flutter Package

## Installation 💻

**❗ In order to start using Supabase Codegen Flutter you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Install via `flutter pub add`:

```sh
flutter pub add supabase_codegen_flutter
```

---

## ✨ Features

- Automatically generates Dart classes from Supabase tables
- Creates type-safe models with full IDE support
- Supports complex relationships and nested structures
- Generates getters and setters for all fields
- Field getter fallback to non-function default values set in the database
- Flutter-optimized client management
- Convenient access to Supabase services (auth, realtime, storage, functions)
- Automatic environment file loading from `config.env`
- Better integration with `supabase_flutter`

## 📋 Prerequisites

- Flutter project with Supabase integration
- Supabase project with tables
- Dart/Flutter development environment

## 🛠️ Setup

1. Install the package. See [Installation](#installation-)
1. Create the SQL functions in Supabase to extract the types.
   Options:
   - Copy and run the sql from [get_schema_info](https://github.com/Khuwn-Soulutions/supabase_codegen/blob/main/packages/supabase_codegen/bin/sql/get_schema_info.dart) and [get_enum_types](https://github.com/Khuwn-Soulutions/supabase_codegen/blob/main/packages/supabase_codegen/bin/sql/get_enum_types.dart) in your Supabase project.

   - Create migration to apply to your local or remote database with `dart run supabase_codegen:add_codegen_functions` and apply the migration with [`supabase migration up`](https://supabase.com/docs/reference/cli/supabase-migration-up).
   Note: this requires [Supabase CLI](https://supabase.com/docs/reference/cli/introduction) with linked project

1. Create an [environment file](#environment-file) at the root of your Flutter project.
1. Add any necessary configuration for type generation. See [Yaml configuration](#yaml-configuration).

## Environment file

The environment file should contain the following.
  - `SUPABASE_URL`: The API url for your Supabase instance.
  - `SUPABASE_ANON_KEY`: Anonymous key (Recommended for Flutter)
  OR
  - `SUPABASE_KEY`: Service Role key. (Not recommended for use in Flutter projects)

If both `SUPABASE_ANON_KEY` and `SUPABASE_KEY` are present in the environment file `SUPABASE_ANON_KEY` will be used.

**Note:**
- The default environment file name for Flutter is `config.env` (not `.env`)
- The environment file must be added to the `assets` section of your `pubspec.yaml`:
```yaml
flutter:
  assets:
    - config.env
```

## Generating types

Run the generation script by executing the following.

```bash
dart run supabase_codegen_flutter:generate_types
```

### Command Line Options

The following command-line options can be used to customize the type generation process:

- `-e, --env <env_file>` (Default: config.env for Flutter):

Specifies the path to the env file containing your Supabase credentials.
Example: `dart run supabase_codegen_flutter:generate_types -e .env.local`

- `-o, --output <output_folder>` (Default: supabase/types):

Sets the directory where the generated type files will be placed.
Example: `dart run supabase_codegen_flutter:generate_types -o lib/models/supabase`

- `-t, --tag <tag>` (Default: ''):

Adds a tag to the generated files to help with versioning or distinguishing between different schemas.
Example: `dart run supabase_codegen_flutter:generate_types -t v2`

If set, the tag will appear at the end of the files following the file generation timestamp like this
```dart
/// Date: 2025-03-06 15:43:24.078502
/// Tag: v2
```

- `-c, --config-yaml  <config yaml path>`

Path to config yaml file, defaults to `.supabase_codegen.yaml`.
If not specified, reads from keys under `supabase_codegen` in `pubspec.yaml`.
See [Yaml configuration](#yaml-configuration)

- `-d, --debug` (Default: false):

Enables debug logging to provide more verbose output during the type generation.
Example: `dart run supabase_codegen_flutter:generate_types -d`

- `-s, --[no-]skip-footer`

Skip the writing of the footer in the generated files.
Example: `dart run supabase_codegen_flutter:generate_types --skip-footer`

- `-h, --help`

Show command line usage options
Example: `dart run supabase_codegen_flutter:generate_types --help`

## Yaml configuration
Instead of providing the options via the command line, you can also set them in a yaml file.
This can be either in the config yaml file (default `.supabase_codegen.yaml`) or in your `pubspec.yaml` file under the `supabase_codegen` key.
This allows setting default values, and you only need to override them if needed from the command line.

Example config file e.g. `.supabase_codegen.yaml`
```yaml
env: .env.development # Overrides default: config.env
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
  supabase_codegen_flutter: ^1.4.0

flutter:
  assets:
    - config.env

supabase_codegen:
  env: env.app # Overrides default: config.env
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

### Postgres → Dart type mapping

The generator maps common PostgreSQL types to Dart types by default. You can override any of these defaults using the configuration overrides (see [Schema Overrides](#schema-overrides)).

| PostgreSQL type(s) | Dart type |
| --- | --- |
| text, varchar, char, uuid, character varying, name, bytea | String |
| int2, int4, int8, integer, bigint | int |
| float4, float8, decimal, numeric, double precision | double |
| bool, boolean | bool |
| timestamp, timestamptz, timestamp with time zone, timestamp without time zone | DateTime |
| json, jsonb | dynamic |
| user-defined (enums) | generated enum type (if available) or String |
| arrays (e.g., text[], _int4, ARRAY) | List<baseType> (e.g. List<String>) |
| default / unknown | String |

Note: arrays are detected and mapped to `List<...>` where the inner type follows the mapping above. Enums (user-defined) will map to a generated Dart `enum` when present; otherwise they fall back to `String`.

### Schema Overrides

You can override the generated types for specific columns in your tables. This is useful when you want to use a custom Dart type for a column or modify its nullability.

Overrides are defined under the `override` key in your `.supabase_codegen.yaml` or `pubspec.yaml` file.

The structure for an override is as follows:

```yaml
override:
  <table_name>:
    <column_name>:
      data_type: <Dart_type>
      is_nullable: <true_or_false>
      column_default: <default_value>
```

**Example:**

In the following example, for the `test_table` table, the `id` column is made nullable and the `json_values` column's data type is changed to `dynamic`.

```yaml
supabase_codegen:
  # ... other settings
  override:
    test_table:
      id:
        is_nullable: true
      json_values:
        data_type: dynamic
```

**Override Options:**

For each column, you can specify the following override options:

-   `data_type` (String): The Dart type to use for the column. Remember to include any necessary imports in the file where you use the generated code.
-   `is_nullable` (bool): Whether the generated property should be nullable.
-   `column_default` (dynamic): A default value for the property in the Dart class.

## Client Configuration

Before accessing the [generated types](#generated-types) in your Flutter application ensure that the Supabase client is configured for use.

### Automatic Setup

By default, the package will look for the [environment file](#environment-file) at `config.env` and load the client using the credentials contained there.
If this matches your setup, no further changes are needed.

### Using credential values

To create a client using the credential values the `createClient` function can be used as shown below.
```dart
await createClient('https://my.supabase.com...', 'my-super-safe-key');
```

### Load values from environment file

To configure the client by loading the values from an [environment file](#environment-file) the `loadClientFromEnv` function should be run specifying the path to the environment file if it differs from the default.

```dart
await loadClientFromEnv();
```

### Setting the client

A previously created SupabaseClient can be provided to the `setClient` method to set the client for use by the [generated types](#generated-types).

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

await Supabase.initialize(
  url: SUPABASE_URL,
  anonKey: SUPABASE_ANON_KEY,
);
setClient(Supabase.instance.client);
```

## 📦 Package Exports and Usage

The `supabase_codegen_flutter` package provides convenient access to Supabase services through two main entry points:

### `supabase_codegen_flutter.dart`

This file provides direct access to Supabase service instances:

```dart
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

// Access Supabase services directly
final supabase = supabase; // Supabase instance
final client = supabaseClient; // SupabaseClient
final auth = authClient; // GoTrueClient
final realtime = realtimeClient; // RealtimeClient
final storage = storageClient; // SupabaseStorageClient
final functions = functionsClient; // FunctionsClient
```

### `supabase_client.dart`

This file provides Flutter-optimized client management functions:

```dart
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart'
show env, // Map<String, String> of loaded environment variables
     createClient, 
     loadClientFromEnv, 
     loadSupabaseClient, 
     setClient, 
     loadMockSupabaseClient;


/// Client management functions
// Create client with credentials
await createClient('https://my.supabase.com', 'my-key');

// Load from config.env
await loadClientFromEnv();

 // Set custom client
await Supabase.initialize(
  url: SUPABASE_URL,
  anonKey: SUPABASE_ANON_KEY,
);
setClient(Supabase.instance.client);

/// Testing
// Load mock client for testing
await loadMockSupabaseClient();
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
    /* Lines 250-256 omitted */
    DateTime? createdAt,
  }) : super({
          /* Lines 258-266 omitted */

  /// Users Row
  const UsersRow._(super.data);

  /// Create Users Row from a [data] map
  factory UsersRow.fromJson(Map<String, dynamic> data) =>
      /* Lines 272-273 omitted */

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


```

## 🚀 Usage Examples

### Basic Setup

```dart
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

void main() async {
  // Load client from config.env
  await loadClientFromEnv();

  runApp(const MyApp());
}
```

### Creating Records

```dart
final usersTable = UsersTable();

// Create new record
final adminUser = await usersTable.insert({
  UsersRow.emailField: 'admin@example.com',
  UsersRow.roleField: UserRole.admin,
});

// The returned object is already typed
print(adminUser.email);
print(adminUser.role);
```

### Reading Data

```dart
final usersTable = UsersTable();

// Fetch a single user
final user = await usersTable.querySingleRow(
  queryFn: (q) => q.eq(UsersRow.idField, userId),
);

// Access typed properties
print(user.email);
print(user.role);
```

### Authentication

```dart
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

// Sign up
await authClient.signUp(
  email: 'user@example.com',
  password: 'password',
);

// Sign in
await authClient.signInWithPassword(
  email: 'user@example.com',
  password: 'password',
);

// Get current user
final user = authClient.currentUser;
```

### Realtime Subscriptions

```dart
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

// Subscribe to table changes
final subscription = realtimeClient
  .channel('users')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'users',
    callback: (payload) {
      print('User changed: ${payload.newRecord}');
    },
  )
  .subscribe();
```

## Testing
### Unit Tests

To run the unit tests, use the following command:

```bash
flutter test
```

### Using mocks

To load a preconfigured mock supabase client for testing run `loadMockSupabaseClient()` during `setUpAll` of your tests.
The variables `mockSupabase` and `mockSupabaseHttpClient` are available for use during testing.
See [supabase_table_test](https://github.com/Khuwn-Soulutions/supabase_codegen/blob/main/packages/supabase_codegen/test/src/supabase/database/supabase_table_test.dart) for an example of this in action.

For further details about these mock clients see [MockSupabaseHttpClient](https://github.com/supabase-community/mock_supabase_http_client).

## 📝 Notes

- Ensure your Supabase tables have proper primary keys defined
- All generated models are null-safe
- Custom column types are supported through type converters
- The package is optimized for Flutter development with automatic environment loading

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT license - see the [LICENSE](LICENSE) file for details.

---

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
