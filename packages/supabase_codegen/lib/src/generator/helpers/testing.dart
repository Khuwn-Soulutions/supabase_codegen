import 'dart:io';

/// Are we running in test mode
// coverage:ignore-file
final isRunningInTest =
    Platform.script.path.contains('test.dart') ||
    Platform.environment['FLUTTER_TEST'] == 'true';
