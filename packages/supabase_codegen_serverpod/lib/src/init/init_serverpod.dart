import 'dart:io';

import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Config file path
const configPath = 'config/generator.yaml';

/// Json class import
const jsonClassImport =
    'package:supabase_codegen_serverpod/json_class.dart:JsonClass';

/// Add extra classes to generator config
Future<void> addExtraClassesToGeneratorConfig({
  Logger? logger,
  Directory? directory,
}) async {
  final log = logger ?? Logger(); // coverage:ignore-line
  final dir = directory ?? Directory.current; //coverage:ignore-line
  final generatorConfig = File('${dir.path}/$configPath');

  if (!generatorConfig.existsSync()) {
    log.warn('⚠️ $configPath not found. Skipping extraClasses update.');
    return;
  }

  try {
    final content = await generatorConfig.readAsString();
    final doc = YamlEditor(content);
    final yaml = loadYaml(content) as YamlMap;

    const extraClassesKey = 'extraClasses';

    if (!yaml.containsKey(extraClassesKey)) {
      doc.update([extraClassesKey], [jsonClassImport]);
    } else {
      final currentClasses = yaml[extraClassesKey] as YamlList;
      final exists = currentClasses.any((element) {
        if (element is String) {
          return element == jsonClassImport;
        }
        return false;
      });

      if (!exists) {
        doc.appendToList([extraClassesKey], jsonClassImport);
      }
    }

    if (doc.edits.isNotEmpty) {
      await generatorConfig.writeAsString(doc.toString());
      log.success('✅ Added JsonClass to $configPath');
    } else {
      log.info('✅ JsonClass already exists in $configPath');
    }
  } on Exception catch (e) {
    log.err('❌ Failed to update $configPath: $e');
  }
}
