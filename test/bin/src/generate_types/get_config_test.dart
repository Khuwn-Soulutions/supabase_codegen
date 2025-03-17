import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../bin/src/src.dart';

// Mocking classes and functions
class MockFile extends Mock implements File {}

void main() {
  group('getPubspecConfig', () {
    late MockFile mockPubspecFile;

    setUp(() {
      mockPubspecFile = MockFile();
    });

    tearDown(() {
      reset(mockPubspecFile);
    });

    test('returns correct config', () {
      // Arrange
      const pubspecContent = '''
        name: test_package
        supabase_codegen:
          env: .testenv
          output: test/output
          tag: testtag
          debug: true
          skipFooter: true
      ''';

      // Mock File.readAsStringSync
      when(() => mockPubspecFile.readAsStringSync()).thenReturn(pubspecContent);

      // Act
      final result = getPubspecConfig(mockPubspecFile);

      // Assert
      expect(result['env'], '.testenv');
      expect(result['output'], 'test/output');
      expect(result['tag'], 'testtag');
      expect(result['debug'], true);
      expect(result['skipFooter'], true);
    });

    test('returns empty config if no supabase_codegen key', () {
      // Arrange
      const pubspecContent = '''
        name: test_package
      ''';
      // Mock File.readAsStringSync
      when(() => mockPubspecFile.readAsStringSync()).thenReturn(pubspecContent);

      // Act
      final result = getPubspecConfig(mockPubspecFile);

      // Assert
      expect(result, isEmpty);
    });
  });
}
