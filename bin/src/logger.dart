import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

/// Logger
late final Logger logger;

/// Test logger
@visibleForTesting
final Logger testLogger = Logger(
  level: Level.off,
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    excludeBox: {Level.debug: true, Level.info: true},
    printEmojis: false,
  ),
);
