import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

/// A simple logger that uses the talker package.
late Logger logger;

/// Test logger instance
@visibleForTesting
final Logger testLogger = Logger(level: Level.verbose);

/// Create verbose logger
void createVerboseLogger() => logger = testLogger;
