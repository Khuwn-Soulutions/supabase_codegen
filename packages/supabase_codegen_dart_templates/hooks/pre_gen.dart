import 'package:mason/mason.dart';

void run(HookContext context) {
  // Set the date to now
  final date = DateTime.now().toString();

  // Check if the tag has been set
  final hasTag = (context.vars['tag']?.toString() ?? '').isNotEmpty;
  context.vars['hasTag'] = hasTag;

  // Set tables to null if

  // Log and set date
  context.logger.info('Setting date to $date');
  context.vars['date'] = date;
}
