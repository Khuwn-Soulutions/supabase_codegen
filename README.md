# Supabase Codegen

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/bf5235675f5f4d769f959ddc797ed998)](https://app.codacy.com/gh/Khuwn-Soulutions/supabase_codegen/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

A comprehensive suite of packages for generating type-safe Dart models from Supabase databases, supporting both pure Dart and Flutter applications.

## 📦 Packages

This monorepo contains two main packages:

### [supabase_codegen](packages/supabase_codegen/)
[![pub package](https://img.shields.io/pub/v/supabase_codegen.svg)](https://pub.dev/packages/supabase_codegen)

The core package for generating type-safe Dart models from Supabase tables. Perfect for:
- Pure Dart applications
- Server-side Dart projects
- Custom Dart environments

### [supabase_codegen_flutter](packages/supabase_codegen_flutter/)
[![pub package](https://img.shields.io/pub/v/supabase_codegen_flutter.svg)](https://pub.dev/packages/supabase_codegen_flutter)

Flutter-optimized package that extends the core functionality with Flutter-specific features:
- Automatic environment file loading from `config.env`
- Convenient getters for Supabase services (auth, realtime, storage, functions)
- Better integration with `supabase_flutter`
- Flutter-specific client management

## ✨ Features

- **Type-Safe Models**: Automatically generates strongly-typed Dart classes from your Supabase tables
- **Full IDE Support**: Complete IntelliSense and autocomplete for all generated models
- **Complex Relationships**: Supports nested structures and table relationships
- **Null Safety**: All generated models are fully null-safe
- **Custom Types**: Support for enums and custom column types
- **Flexible Configuration**: YAML-based configuration with command-line overrides
- **Flutter Integration**: Specialized package for Flutter development
- **Testing Support**: Built-in mock clients for comprehensive testing

## 🚀 Quick Start

### For Flutter Projects

1. **Install the Flutter package:**
   ```bash
   flutter pub add supabase_codegen_flutter
   ```

2. **Set up your environment:**
   Create `config.env` in your project root:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

3. **Add to pubspec.yaml:**
   ```yaml
   flutter:
     assets:
       - config.env
   ```

4. **Generate types:**
   ```bash
   dart run supabase_codegen_flutter:generate_types
   ```

5. **Use in your app:**
   ```dart
   import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

   void main() async {
     await loadClientFromEnv();
     runApp(const MyApp());
   }
   ```

### For Pure Dart Projects

1. **Install the core package:**
   ```bash
   dart pub add supabase_codegen
   ```

2. **Set up your environment:**
   Create `.env` in your project root:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

3. **Generate types:**
   ```bash
   dart run supabase_codegen:generate_types
   ```

4. **Use in your app:**
   ```dart
   import 'package:supabase_codegen/supabase_codegen.dart';

   void main() async {
     loadClientFromEnv();
     // Your app code here
   }
   ```

## 🛠️ Development

This project uses [Melos](https://melos.invertase.dev/) for monorepo management.

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for Flutter package development)
- [Melos](https://melos.invertase.dev/getting-started) for workspace management

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Khuwn-Soulutions/supabase_codegen.git
   cd supabase_codegen
   ```

2. **Install dependencies:**
   ```bash
   dart pub get
   melos bootstrap
   ```

3. **Run tests:**
   ```bash
   melos run test
   ```

4. **Run tests with coverage:**
   ```bash
   melos run test:coverage
   ```

### Project Structure

```
supabase_codegen/
├── packages/
│   ├── supabase_codegen/           # Core Dart package
│   │   ├── bin/                    # CLI tools
│   │   ├── lib/                    # Source code
│   │   ├── test/                   # Unit tests
│   │   └── example/                # Usage examples
│   └── supabase_codegen_flutter/   # Flutter package
│       ├── bin/                    # CLI tools
│       ├── lib/                    # Source code
│       ├── test/                   # Unit tests
│       └── example/                # Flutter example app
├── .github/
│   └── workflows/                  # CI/CD pipelines
└── analysis_options.yaml           # Code analysis configuration
```

### Available Scripts

- `melos run test` - Run all tests
- `melos run test:coverage` - Run tests with coverage
- `melos run coverage_badge` - Update coverage badges
- `melos run test:coverage_badge` - Run tests and update badges

## 📋 Prerequisites for Development

- Supabase project with tables
- Dart/Flutter development environment
- Supabase CLI (for local development)

## 🧪 Testing

The project includes comprehensive test suites for both packages:

### Unit Tests
```bash
# Run all tests
melos run test

# Run with coverage
melos run test:coverage
```

### Integration Tests
Each package includes example projects that demonstrate real-world usage and serve as integration tests.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Run tests: `melos run test`
5. Submit a pull request

### Code Quality

This project uses:
- [Very Good Analysis](https://pub.dev/packages/very_good_analysis) for strict linting
- [Very Good Workflows](https://github.com/VeryGoodOpenSource/very_good_workflows) for CI/CD
- Comprehensive test coverage requirements

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built using the great work by [Kennerd](https://github.com/Kemerd) at [Supabase Flutter Codegen](https://github.com/Kemerd/supabase-flutter-codegen)
- Powered by [Very Good Ventures](https://verygood.ventures) tooling

## 📞 Support

- [GitHub Issues](https://github.com/Khuwn-Soulutions/supabase_codegen/issues) for bug reports and feature requests
- [Discussions](https://github.com/Khuwn-Soulutions/supabase_codegen/discussions) for questions and community support

---

**Made with ❤️ by [Khuwn Soulutions](https://github.com/Khuwn-Soulutions)**

[dart_install_link]: https://dart.dev/get-dart
[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows</content>
