import 'package:dcli/dcli.dart';

/// Get the tag to use in the header of generated files
String getTag({bool addTag = false, String? tag}) {
  final useTag = confirm(
    'Do you want to add a tag to the generated files?',
    defaultValue: addTag,
  );

  return useTag
      ? ask(
          'Enter the tag to use in the generated files',
          defaultValue: tag ?? '',
        )
      : '';
}
