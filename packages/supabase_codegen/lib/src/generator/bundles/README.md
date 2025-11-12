# Templates

This folder contains the bundled versions of the bricks generated from [supabase_codegen_templates](../../../../../supabase_codegen_templates)
using [Mason](https://pub.dev/packages/mason).

## Bricks

| Name             | Version | Description                                        |
| ---------------- | ------- | -------------------------------------------------- |
| barrel_files     | 0.1.0+1 | Brick to generate barrel files for Supabase Codegen |
| tables_and_enums | 0.1.0+1 | Brick to generate tables and enums for Supabase Codegen |

## Generating bundles
1. Ensure that the [mason-cli](https://pub.dev/packages/mason_cli) is installed globally.
```sh
dart pub global activate mason_cli
```
1. Generate brick bundles from project root.
```sh
dart run scripts/bundle_bricks.dart
```

## Usage
See [Using Dart Bundles](https://docs.brickhub.dev/mason-bundle#-using-dart-bundles) for usage.
