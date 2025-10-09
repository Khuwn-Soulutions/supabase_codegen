import 'package:talker/talker.dart';

/// A simple logger that uses the talker package.
late final Talker talker;

/// The global logger instance
Talker get logger => talker;

/// Test logger instance
final Talker testLogger = Talker();
