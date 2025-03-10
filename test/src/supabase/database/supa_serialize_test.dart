import 'package:latlng/latlng.dart';
import 'package:supabase_codegen/src/supabase/database/supa_serialize.dart';
import 'package:test/test.dart';

enum TestEnum {
  value1,
  value2;
}

void main() {
  group('supaSerialize', () {
    test('serializes null values', () {
      expect(supaSerialize<String>(null), isNull);
    });

    test('serializes DateTime objects to ISO 8601 string', () {
      final now = DateTime.now();
      expect(supaSerialize<DateTime>(now), now.toIso8601String());
    });

    test('serializes LatLng objects to map', () {
      const lat = 48.8584;
      const lng = 2.2945;
      final latLng = LatLng.degree(lat, lng);
      expect(supaSerialize<LatLng>(latLng), {
        'lat': lat,
        'lng': lng,
      });
    });

    test('serializes Enums to their name', () {
      expect(supaSerialize<TestEnum>(TestEnum.value1), 'value1');
    });

    test('serializes other types as-is', () {
      expect(supaSerialize<String>('test'), 'test');
      expect(supaSerialize<int>(123), 123);
      expect(supaSerialize<double>(3.14), 3.14);
      expect(supaSerialize<bool>(true), true);
    });
  });

  group('supaSerializeList', () {
    test('serializes null list', () {
      expect(supaSerializeList<String>(null), isNull);
    });

    test('serializes a list of DateTime', () {
      final now = DateTime.now();
      final list = [now, now.add(const Duration(days: 1))];
      final result = supaSerializeList<DateTime>(list);
      expect(result, [
        now.toIso8601String(),
        now.add(const Duration(days: 1)).toIso8601String(),
      ]);
    });

    test('serializes a list of LatLng', () {
      final latLng1 = LatLng.degree(48.8584, 2.2945);
      final latLng2 = LatLng.degree(40.7128, -74.0060);
      final list = [latLng1, latLng2];
      final result = supaSerializeList<LatLng>(list);
      expect(result, [
        {'lat': 48.8584, 'lng': 2.2945},
        {'lat': 40.7128, 'lng': -74.0060},
      ]);
    });

    test('serializes a list of Enums', () {
      final list = [TestEnum.value1, TestEnum.value2];
      final result = supaSerializeList<TestEnum>(list);
      expect(result, ['value1', 'value2']);
    });

    test('serializes a list of String', () {
      final list = ['test', 'test2'];
      final result = supaSerializeList<String>(list);
      expect(result, ['test', 'test2']);
    });

    test('serializes a list of int', () {
      final list = [1, 2];
      final result = supaSerializeList<int>(list);
      expect(result, [1, 2]);
    });
  });

  group('supaDeserialize', () {
    test('deserializes null values', () {
      expect(supaDeserialize<String>(null), isNull);
    });

    test('deserializes int', () {
      expect(supaDeserialize<int>(123), 123);
      expect(supaDeserialize<int>(123.5), 124);
    });

    test('deserializes double', () {
      expect(supaDeserialize<double>(3.14), 3.14);
      expect(supaDeserialize<double>(3), 3.0);
    });

    test('deserializes DateTime from String', () {
      final now = DateTime.now();
      final result = supaDeserialize<DateTime>(now.toIso8601String());
      expect(result?.toIso8601String(), now.toLocal().toIso8601String());
    });

    test('deserializes LatLng from map', () {
      final result = supaDeserialize<LatLng>({'lat': 48.8584, 'lng': 2.2945});
      expect(result?.latitude.degrees, 48.8584);
      expect(result?.longitude.degrees, 2.2945);
    });

    test('deserializes LatLng from map with latitude and longitude', () {
      final result =
          supaDeserialize<LatLng>({'latitude': 48.8584, 'longitude': 2.2945});
      expect(result?.latitude.degrees, 48.8584);
      expect(result?.longitude.degrees, 2.2945);
    });

    test('deserializes LatLng from json string', () {
      const json = '{"lat": 48.8584, "lng": 2.2945}';
      final result = supaDeserialize<LatLng>(json);
      expect(result?.latitude.degrees, 48.8584);
      expect(result?.longitude.degrees, 2.2945);
    });

    test('deserializes LatLng with missing properties', () {
      expect(supaDeserialize<LatLng>({'lat': 48.8584}), isNull);
      expect(supaDeserialize<LatLng>({'lng': 2.2945}), isNull);
      expect(supaDeserialize<LatLng>(<dynamic, dynamic>{}), isNull);
    });

    test('deserializes String', () {
      expect(supaDeserialize<String>('test'), 'test');
    });

    test('deserializes bool', () {
      expect(supaDeserialize<bool>(true), true);
    });

    test('deserializes Enums', () {
      expect(
        supaDeserialize<TestEnum>('value1', enumValues: TestEnum.values),
        TestEnum.value1,
      );
      expect(
        supaDeserialize<TestEnum>('value2', enumValues: TestEnum.values),
        TestEnum.value2,
      );
      expect(
        supaDeserialize<TestEnum>('invalid', enumValues: TestEnum.values),
        isNull,
      );
    });

    test('deserializes other types as-is', () {
      final map = {'a': 1, 'b': 2};
      expect(supaDeserialize<Map<dynamic, dynamic>>(map), map);
    });
  });

  group('supaDeserializeList', () {
    test('deserializes a list of int', () {
      final list = [1, 2, 3];
      final result = supaDeserializeList<int>(list);
      expect(result, list);
    });

    test('deserializes a list of double', () {
      final list = [1.0, 2.2, 3.3];
      final result = supaDeserializeList<double>(list);
      expect(result, list);
    });

    test('deserializes a list of String', () {
      final list = ['1', '2', '3'];
      final result = supaDeserializeList<String>(list);
      expect(result, list);
    });

    test('deserializes a list of DateTime', () {
      final now = DateTime.now();
      final list = [
        now.toIso8601String(),
        now.add(const Duration(days: 1)).toIso8601String(),
      ];
      final result = supaDeserializeList<DateTime>(list);
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result, list.map(DateTime.parse).toList());
    });

    test('deserializes a list of null values', () {
      final list = [null, null, null];
      final result = supaDeserializeList<String>(list);
      expect(result, isEmpty);
    });

    test('deserializes a list of mixed values', () {
      final list = [1, '2', 3.3, null];
      final result = supaDeserializeList<dynamic>(list);
      expect(result, list..removeLast());
    });

    test('deserializes a list of Enums', () {
      final list = ['value1', 'value2'];
      final result = supaDeserializeList<TestEnum>(
        list,
        enumValues: TestEnum.values,
      );
      expect(result, [TestEnum.value1, TestEnum.value2]);
    });
  });
}
