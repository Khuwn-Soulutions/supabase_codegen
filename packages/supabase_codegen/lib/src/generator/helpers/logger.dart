import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

/// A simple logger using mason_logger package.
Logger logger = Logger();

/// Test logger instance
@visibleForTesting
final Logger testLogger = Logger(level: Level.verbose);

/// Create verbose logger
void createVerboseLogger() => logger = testLogger;
