# Supabase Codegen Serverpod

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A codegen library that generates `.spy.yaml` models for [Serverpod](https://serverpod.dev/) from your Supabase tables and enums.

## Installation 💻

**❗ In order to start using Supabase Codegen Serverpod you must have the [Dart SDK][dart_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add supabase_codegen_serverpod
```

> **Note:** This package should be installed in your **Serverpod server project** (typically `my_serverpod_server`).

---

## 🛠️ Setup

1. **Initialize the configuration:**
   
   Run the init command to create the default configuration:
   ```sh
   dart run supabase_codegen_serverpod:init
   ```
   This will help you set up your `pubspec.yaml` or `.supabase_codegen.yaml` configuration.

2. **Configure your environment:**
   
   Ensure you have your Supabase credentials in your environment file (default `.env`):
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

## 🚀 Usage

### Generating Models

To generate the Serverpod `.spy.yaml` files, run:

```sh
dart run supabase_codegen_serverpod:generate_types
```

By default, this will:
1. Read your Supabase schema
2. Generate corresponding `.spy.yaml` files in `lib/src/models` (or your configured output directory)
3. Exclude any tables starting with `serverpod`

### Configuration Options

You can configure the generator via CLI arguments or YAML configuration.

#### CLI Arguments

- `-e, --env <path>`: Path to environment file (default: `.env`)
- `-o, --output <path>`: Output directory for generated files (default: `lib/src/models`)
- `-t, --tag <tag>`: Optional tag to add to generated files
- `-d, --debug`: Enable debug logging

#### YAML Configuration

You can add configuration to `pubspec.yaml` or `.supabase_codegen.yaml`:

```yaml
supabase_codegen:
  env: .env.development
  output: lib/src/protocol
  # ... other options
```

---

## Continuous Integration 🤖

Supabase Codegen Serverpod comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.15.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
