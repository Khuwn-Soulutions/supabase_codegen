import 'dart:io';

import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Config file path
const configPath = 'config/generator.yaml';

/// Add extra classes to generator config
Future<void> addExtraClassesToGeneratorConfig({
  Logger? logger,
  Directory? directory,
}) async {
  final log = logger ?? Logger();
  final dir = directory ?? Directory.current;
  final generatorConfig = File('${dir.path}/$configPath');

  if (!generatorConfig.existsSync()) {
    log.warn('$configPath not found. Skipping extraClasses update.');
    return;
  }

  try {
    final content = await generatorConfig.readAsString();
    final doc = YamlEditor(content);
    final yaml = loadYaml(content) as YamlMap;

    const extraClassesKey = 'extraClasses';
    const jsonClassConfig = {
      'package': 'supabase_codegen_serverpod/json_class.dart:JsonClass',
    };

    if (!yaml.containsKey(extraClassesKey)) {
      doc.update([extraClassesKey], [jsonClassConfig]);
    } else {
      final currentClasses = yaml[extraClassesKey] as YamlList?;
      if (currentClasses != null) {
        final exists = currentClasses.any((element) {
          if (element is YamlMap) {
            return element['package'] == jsonClassConfig['package'];
          }
          return false;
        });

        if (!exists) {
          doc.appendToList([extraClassesKey], jsonClassConfig);
        }
      } else {
        // If extraClasses exists but is null or not a list, overwrite
        // Assuming it should be a list, we can initialize it.
        doc.update([extraClassesKey], [jsonClassConfig]);
      }
    }

    if (doc.edits.isNotEmpty) {
      await generatorConfig.writeAsString(doc.toString());
      log.success('Added JsonClass to $configPath');
    } else {
      log.detail('JsonClass already exists in $configPath');
    }
  } on Exception catch (e) {
    log.err('Failed to update $configPath: $e');
  }
}
