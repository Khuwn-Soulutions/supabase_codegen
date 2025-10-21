import 'package:meta/meta.dart';
import 'package:talker/talker.dart';

/// A simple logger that uses the talker package.
late Talker logger;

/// Test logger instance
@visibleForTesting
final Talker testLogger = Talker(
  logger: TalkerLogger(
    formatter: const ColoredLoggerFormatter(),
    settings: TalkerLoggerSettings(
      lineSymbol: '',
    ),
  ),
);

/// Create verbose logger
void createVerboseLogger() => logger = testLogger;
