## 1.2.0 - 2025-04-01

### Features

- toJson method added to generated row data class

## Bug Fixes

- suppress analyzer warnings for capitalized enum members
- DateTime not correctly copied in copyWith

## 1.1.0 - 2025-03-18

### Features

- generate_types: add command line option to skip footer
- generate_types: add help option to display command line options usage
- extensions: add JSON extension for cleaning null key-value pairs
- generate_table: update fromJson factory to use cleaned data map
- generators: add ignore_for_file comment for trailing commas in generated files

### Bug Fixes

- generate_types: update copyWith methods to use fromJson constructor

### Refactor

- generators: modularize code by separating into dedicated files
- generators: move generators to lib folder

## 1.0.1 - 2025-03-10
Ensured version written in footer in sync with package version.

## 1.0.0 - 2025-03-10
First release!
