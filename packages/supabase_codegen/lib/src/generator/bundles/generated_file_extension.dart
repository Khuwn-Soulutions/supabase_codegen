import 'package:mason/mason.dart';

/// Extension methods for GeneratedFile
extension GeneratedFileExtension on GeneratedFile {
  /// Copy with new path and/or status
  GeneratedFile copyWith({String? path, GeneratedFileStatus? status}) {
    switch (status ?? this.status) {
      case GeneratedFileStatus.appended:
        return GeneratedFile.appended(path: path ?? this.path);
      case GeneratedFileStatus.created:
        return GeneratedFile.created(path: path ?? this.path);
      case GeneratedFileStatus.identical:
        return GeneratedFile.identical(path: path ?? this.path);
      case GeneratedFileStatus.overwritten:
        return GeneratedFile.overwritten(path: path ?? this.path);
      case GeneratedFileStatus.skipped:
        return GeneratedFile.skipped(path: path ?? this.path);
    }
  }
}
