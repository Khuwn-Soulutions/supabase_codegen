import 'package:mocktail/mocktail.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/src/supabase/database/filter_extensions.dart';
import 'package:test/test.dart';

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockSupabaseStreamBuilder extends Mock
    implements SupabaseStreamFilterBuilder {}

void main() {
  group('NullSafePostgrestFilters', () {
    late MockPostgrestFilterBuilder<dynamic> mockBuilder;

    setUp(() {
      mockBuilder = MockPostgrestFilterBuilder<dynamic>();
      // Register fallback value
      registerFallbackValue(mockBuilder);
    });

    test('eqOrNull applies eq filter when value is not null', () {
      when(() => mockBuilder.eq('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.eqOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.eq('column', 'value')).called(1);
    });

    test('eqOrNull does not apply filter when value is null', () {
      final result = mockBuilder.eqOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.eq(any(), any()));
    });

    test('neqOrNull applies neq filter when value is not null', () {
      when(() => mockBuilder.neq('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.neqOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.neq('column', 'value')).called(1);
    });

    test('neqOrNull does not apply filter when value is null', () {
      final result = mockBuilder.neqOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.neq(any(), any()));
    });

    test('ltOrNull applies lt filter when value is not null', () {
      when(() => mockBuilder.lt('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.ltOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.lt('column', 'value')).called(1);
    });

    test('ltOrNull does not apply filter when value is null', () {
      final result = mockBuilder.ltOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.lt(any(), any()));
    });

    test('lteOrNull applies lte filter when value is not null', () {
      when(() => mockBuilder.lte('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.lteOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.lte('column', 'value')).called(1);
    });

    test('lteOrNull does not apply filter when value is null', () {
      final result = mockBuilder.lteOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.lte(any(), any()));
    });

    test('gtOrNull applies gt filter when value is not null', () {
      when(() => mockBuilder.gt('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.gtOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.gt('column', 'value')).called(1);
    });

    test('gtOrNull does not apply filter when value is null', () {
      final result = mockBuilder.gtOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.gt(any(), any()));
    });

    test('gteOrNull applies gte filter when value is not null', () {
      when(() => mockBuilder.gte('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.gteOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.gte('column', 'value')).called(1);
    });

    test('gteOrNull does not apply filter when value is null', () {
      final result = mockBuilder.gteOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.gte(any(), any()));
    });

    test('containsOrNull applies contains filter when value is not null', () {
      when(() => mockBuilder.contains('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.containsOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.contains('column', 'value')).called(1);
    });

    test('containsOrNull does not apply filter when value is null', () {
      final result = mockBuilder.containsOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.contains(any(), any()));
    });

    test('overlapsOrNull applies overlaps filter when value is not null', () {
      when(() => mockBuilder.overlaps('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.overlapsOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.overlaps('column', 'value')).called(1);
    });

    test('overlapsOrNull does not apply filter when value is null', () {
      final result = mockBuilder.overlapsOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.overlaps(any(), any()));
    });

    test('inFilterOrNull applies inFilter when values is not null', () {
      final values = ['value1', 'value2'];
      when(() => mockBuilder.inFilter('column', values))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.inFilterOrNull('column', values);
      expect(result, mockBuilder);
      verify(() => mockBuilder.inFilter('column', values)).called(1);
    });

    test('inFilterOrNull does not apply filter when values is null', () {
      final result = mockBuilder.inFilterOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.inFilter(any(), any()));
    });
  });

  group('NullSafeSupabaseStreamFilters', () {
    late MockSupabaseStreamBuilder mockBuilder;

    setUp(() {
      mockBuilder = MockSupabaseStreamBuilder();
      registerFallbackValue(mockBuilder);
    });

    test('eqOrNull applies eq filter when value is not null', () {
      when(() => mockBuilder.eq('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.eqOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.eq('column', 'value')).called(1);
    });

    test('eqOrNull does not apply filter when value is null', () {
      final result = mockBuilder.eqOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.eq(any(), any()));
    });

    test('neqOrNull applies neq filter when value is not null', () {
      when(() => mockBuilder.neq('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.neqOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.neq('column', 'value')).called(1);
    });

    test('neqOrNull does not apply filter when value is null', () {
      final result = mockBuilder.neqOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.neq(any(), any()));
    });

    test('ltOrNull applies lt filter when value is not null', () {
      when(() => mockBuilder.lt('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.ltOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.lt('column', 'value')).called(1);
    });

    test('ltOrNull does not apply filter when value is null', () {
      final result = mockBuilder.ltOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.lt(any(), any()));
    });

    test('lteOrNull applies lte filter when value is not null', () {
      when(() => mockBuilder.lte('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.lteOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.lte('column', 'value')).called(1);
    });

    test('lteOrNull does not apply filter when value is null', () {
      final result = mockBuilder.lteOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.lte(any(), any()));
    });

    test('gtOrNull applies gt filter when value is not null', () {
      when(() => mockBuilder.gt('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.gtOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.gt('column', 'value')).called(1);
    });

    test('gtOrNull does not apply filter when value is null', () {
      final result = mockBuilder.gtOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.gt(any(), any()));
    });

    test('gteOrNull applies gte filter when value is not null', () {
      when(() => mockBuilder.gte('column', 'value'))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.gteOrNull('column', 'value');
      expect(result, mockBuilder);
      verify(() => mockBuilder.gte('column', 'value')).called(1);
    });

    test('gteOrNull does not apply filter when value is null', () {
      final result = mockBuilder.gteOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.gte(any(), any()));
    });

    test('inFilterOrNull applies inFilter when values is not null', () {
      final values = ['value1', 'value2'];
      when(() => mockBuilder.inFilter('column', values))
          .thenAnswer((_) => mockBuilder);
      final result = mockBuilder.inFilterOrNull('column', values);
      expect(result, mockBuilder);
      verify(() => mockBuilder.inFilter('column', values)).called(1);
    });

    test('inFilterOrNull does not apply filter when values is null', () {
      final result = mockBuilder.inFilterOrNull('column', null);
      expect(result, mockBuilder);
      verifyNever(() => mockBuilder.inFilter(any(), any()));
    });
  });
}
