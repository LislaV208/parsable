import 'package:test/test.dart';
import 'package:parsable/parsable.dart';

// Test models
class TestUser extends Parsable {
  const TestUser({required super.data});

  String? get name => get('name');
  int? get age => get('age');
  double? get height => get('height');
  bool? get isActive => get('isActive');
  String? get nonExistent => get('nonExistent');

  factory TestUser.fromMap(Map<String, dynamic> map) => TestUser(data: map);
}

class TestAddress extends Parsable {
  const TestAddress({required super.data});

  String? get street => get('street');
  String? get city => get('city');
  String? get zipCode => get('zipCode');

  factory TestAddress.fromMap(Map<String, dynamic> map) =>
      TestAddress(data: map);
}

class TestUserWithAddress extends Parsable {
  const TestUserWithAddress({required super.data});

  String? get name => get('name');
  TestAddress? get address => get('address', parser: TestAddress.fromMap);
  Map<String, dynamic>? get addressWithoutParser => get('address');
  List<TestAddress> get addresses =>
      getList('addresses', parser: TestAddress.fromMap) ?? [];

  factory TestUserWithAddress.fromMap(Map<String, dynamic> map) =>
      TestUserWithAddress(data: map);
}

void main() {
  group('Basic type parsing', () {
    test('should parse String values correctly', () {
      final user = TestUser.fromMap({'name': 'John Doe'});
      expect(user.name, equals('John Doe'));
    });

    test('should parse int values correctly', () {
      final user = TestUser.fromMap({'age': 30});
      expect(user.age, equals(30));
    });

    test('should parse double values correctly', () {
      final user = TestUser.fromMap({'height': 175.5});
      expect(user.height, equals(175.5));
    });

    test('should parse bool values correctly', () {
      final user = TestUser.fromMap({'isActive': true});
      expect(user.isActive, equals(true));
    });

    test('should parse multiple values at once', () {
      final user = TestUser.fromMap({
        'name': 'Alice',
        'age': 25,
        'height': 165.0,
        'isActive': false,
      });

      expect(user.name, equals('Alice'));
      expect(user.age, equals(25));
      expect(user.height, equals(165.0));
      expect(user.isActive, equals(false));
    });
  });

  group('Null value handling', () {
    test('should return null for missing keys', () {
      final user = TestUser.fromMap({});
      expect(user.name, isNull);
      expect(user.age, isNull);
      expect(user.height, isNull);
      expect(user.isActive, isNull);
    });

    test('should return null for explicitly null values', () {
      final user = TestUser.fromMap({'name': null, 'age': null});
      expect(user.name, isNull);
      expect(user.age, isNull);
    });

    test('should handle partial data correctly', () {
      final user = TestUser.fromMap({'name': 'Bob', 'age': 40});

      expect(user.name, equals('Bob'));
      expect(user.age, equals(40));
      expect(user.height, isNull);
      expect(user.isActive, isNull);
    });
  });

  group('Numeric conversions', () {
    setUp(() {
      // Ensure conversions are enabled for these tests
      Parsable.handleNumericConversions(true);
    });

    test('should convert int to double when requested', () {
      final user = TestUser.fromMap({'height': 180}); // int value
      expect(user.height, equals(180.0));
      expect(user.height, isA<double>());
    });

    test('should convert double to int when requested', () {
      final user = TestUser.fromMap({'age': 25.7}); // double value
      expect(user.age, equals(25));
      expect(user.age, isA<int>());
    });

    test('should handle conversion from int to double with precision', () {
      final user = TestUser.fromMap({'height': 42});
      expect(user.height, equals(42.0));
    });

    test('should truncate when converting double to int', () {
      final user = TestUser.fromMap({'age': 30.9});
      expect(user.age, equals(30));
    });
  });

  group('Numeric conversions disabled', () {
    setUp(() {
      Parsable.handleNumericConversions(false);
    });

    tearDown(() {
      // Re-enable for other tests
      Parsable.handleNumericConversions(true);
    });

    test('should return null when int to double conversion is disabled', () {
      final user = TestUser.fromMap({'height': 180}); // int value
      expect(user.height, isNull);
    });

    test('should return null when double to int conversion is disabled', () {
      final user = TestUser.fromMap({'age': 25.5}); // double value
      expect(user.age, isNull);
    });

    test('should still parse correct types', () {
      final user = TestUser.fromMap({
        'age': 30, // int
        'height': 175.5, // double
      });

      expect(user.age, equals(30));
      expect(user.height, equals(175.5));
    });
  });

  group('Nested object parsing', () {
    test('should parse nested objects with parser', () {
      final user = TestUserWithAddress.fromMap({
        'name': 'Charlie',
        'address': {
          'street': '123 Main St',
          'city': 'Springfield',
          'zipCode': '12345',
        },
      });

      expect(user.name, equals('Charlie'));
      expect(user.address, isNotNull);
      expect(user.address?.street, equals('123 Main St'));
      expect(user.address?.city, equals('Springfield'));
      expect(user.address?.zipCode, equals('12345'));
    });

    test('should return null for nested object with missing data', () {
      final user = TestUserWithAddress.fromMap({'name': 'Dave'});
      expect(user.address, isNull);
    });

    test('should return null for nested object when no parser provided', () {
      final user = TestUserWithAddress.fromMap({
        'name': 'Eve',
        'address': {'street': '456 Oak Ave', 'city': 'Shelbyville'},
      });

      // addressWithoutParser tries to get 'address' without parser
      expect(user.addressWithoutParser, isNull);
    });
  });

  group('Error handling', () {
    test('should handle type mismatch by returning null', () {
      final user = TestUser.fromMap({
        'name': 123, // int instead of String
        'age': 'thirty', // String instead of int
      });

      expect(user.name, isNull);
      expect(user.age, isNull);
    });

    test('should call custom error handler on type mismatch', () {
      final errors = <String>[];
      Parsable.setOnParseError((message) {
        errors.add(message);
      });

      final user = TestUser.fromMap({'name': 123});
      final _ = user.name; // Trigger the error

      expect(errors, isNotEmpty);
      expect(errors.first, contains('Unable to parse property "name"'));

      // Reset to default
      Parsable.setOnParseError((message) {});
    });

    test(
      'should call error handler when parser is missing for nested object',
      () {
        final errors = <String>[];
        Parsable.setOnParseError((message) {
          errors.add(message);
        });

        final user = TestUserWithAddress.fromMap({
          'address': {'street': 'Test St'},
        });
        final _ = user.addressWithoutParser; // Trigger the error

        expect(errors, isNotEmpty);
        expect(errors.first, contains('no parser provided'));

        // Reset to default
        Parsable.setOnParseError((message) {});
      },
    );

    test('should handle exceptions thrown by parser function in get()', () {
      final errors = <String>[];
      Parsable.setOnParseError((message) {
        errors.add(message);
      });

      // Create a parser that throws an exception
      TestAddress throwingParser(Map<String, dynamic> map) {
        throw Exception('Parser failed intentionally');
      }

      // Create a test parsable with the throwing parser
      final testParsable = TestUserWithAddress(data: {
        'address': {'street': 'Test St', 'city': 'Test City'},
      });

      // Try to get address with the throwing parser
      final address = testParsable.get<TestAddress>(
        'address',
        parser: throwingParser,
      );

      // Should return null when parser throws
      expect(address, isNull);

      // Should have logged the error
      expect(errors, isNotEmpty);
      expect(errors.first, contains('Failed to parse property "address"'));
      expect(errors.first, contains('Parser failed intentionally'));

      // Reset error handler
      Parsable.setOnParseError((message) {});
    });
  });

  group('Equatable functionality', () {
    test('should consider two objects with same data as equal', () {
      final user1 = TestUser.fromMap({
        'name': 'John',
        'age': 30,
        'isActive': true,
      });
      final user2 = TestUser.fromMap({
        'name': 'John',
        'age': 30,
        'isActive': true,
      });

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should consider two objects with different data as not equal', () {
      final user1 = TestUser.fromMap({'name': 'John', 'age': 30});
      final user2 = TestUser.fromMap({'name': 'Jane', 'age': 25});

      expect(user1, isNot(equals(user2)));
    });

    test('should handle equality with nested objects having same values', () {
      final user1 = TestUserWithAddress.fromMap({
        'name': 'Alice',
        'address': {'street': '123 Main St', 'city': 'Springfield'},
      });
      final user2 = TestUserWithAddress.fromMap({
        'name': 'Alice',
        'address': {'street': '123 Main St', 'city': 'Springfield'},
      });

      // This test checks if nested maps with same values are considered equal
      expect(user1, equals(user2));
    });

    test('should detect inequality with different nested object values', () {
      final user1 = TestUserWithAddress.fromMap({
        'name': 'Alice',
        'address': {'city': 'Springfield'},
      });
      final user2 = TestUserWithAddress.fromMap({
        'name': 'Alice',
        'address': {'city': 'Shelbyville'},
      });

      expect(user1, isNot(equals(user2)));
    });
  });

  group('toMap functionality', () {
    test('should convert Parsable back to Map', () {
      final originalMap = {
        'name': 'Frank',
        'age': 45,
        'height': 180.5,
        'isActive': true,
      };
      final user = TestUser.fromMap(originalMap);
      final resultMap = user.toMap();

      expect(resultMap, equals(originalMap));
      expect(resultMap['name'], equals('Frank'));
      expect(resultMap['age'], equals(45));
    });

    test('should return the same map reference', () {
      final originalMap = {'name': 'Grace'};
      final user = TestUser.fromMap(originalMap);

      expect(user.toMap(), same(originalMap));
    });

    test('should preserve nested structures in toMap', () {
      final originalMap = {
        'name': 'Henry',
        'address': {'street': '789 Pine Rd', 'city': 'Capital City'},
      };
      final user = TestUserWithAddress.fromMap(originalMap);
      final resultMap = user.toMap();

      expect(resultMap, equals(originalMap));
      expect(resultMap['address'], isA<Map<String, dynamic>>());
      expect((resultMap['address'] as Map)['city'], equals('Capital City'));
    });
  });

  group('Edge cases', () {
    test('should handle empty map', () {
      final user = TestUser.fromMap({});
      expect(user.toMap(), equals({}));
    });

    test('should handle map with unexpected keys', () {
      final user = TestUser.fromMap({
        'name': 'Igor',
        'unexpectedKey': 'unexpectedValue',
        'anotherKey': 123,
      });

      expect(user.name, equals('Igor'));
      expect(user.toMap()['unexpectedKey'], equals('unexpectedValue'));
    });

    test('should handle deeply nested null values', () {
      final user = TestUserWithAddress.fromMap({
        'name': 'Jack',
        'address': {'street': null, 'city': 'TestCity', 'zipCode': null},
      });

      expect(user.address?.street, isNull);
      expect(user.address?.city, equals('TestCity'));
      expect(user.address?.zipCode, isNull);
    });

    test('should work with const constructors', () {
      const map = {'name': 'Kate', 'age': 35};
      const user = TestUser(data: map);

      expect(user.name, equals('Kate'));
      expect(user.age, equals(35));
    });
  });

  group('List parsing with getList', () {
    test('should parse list of objects correctly', () {
      final user = TestUserWithAddress.fromMap({
        'name': 'Test',
        'addresses': [
          {'street': '123 Main St', 'city': 'Springfield'},
          {'street': '456 Oak Ave', 'city': 'Shelbyville'},
        ],
      });

      expect(user.addresses.length, equals(2));
      expect(user.addresses[0].street, equals('123 Main St'));
      expect(user.addresses[1].city, equals('Shelbyville'));
    });

    test('should return empty list for missing key', () {
      final user = TestUserWithAddress.fromMap({'name': 'Test'});

      expect(user.addresses, isEmpty);
    });

    test('should return empty list for explicitly null value', () {
      final user = TestUserWithAddress.fromMap({'addresses': null});

      expect(user.addresses, isEmpty);
    });

    test('should handle empty list', () {
      final user = TestUserWithAddress.fromMap({
        'name': 'Test',
        'addresses': [],
      });

      expect(user.addresses, isEmpty);
    });

    test('should skip invalid items in list', () {
      final errors = <String>[];
      Parsable.setOnParseError((message) {
        errors.add(message);
      });

      final user = TestUserWithAddress.fromMap({
        'addresses': [
          {'street': '123 Main St', 'city': 'Springfield'}, // valid
          'invalid string', // invalid - not a map
          {'street': '456 Oak Ave', 'city': 'Shelbyville'}, // valid
          123, // invalid - not a map
        ],
      });

      // Store result to avoid calling getter multiple times
      final addresses = user.addresses;

      expect(addresses.length, equals(2));
      expect(addresses[0].street, equals('123 Main St'));
      expect(addresses[1].street, equals('456 Oak Ave'));

      // Should have logged errors for invalid items (2 invalid items)
      expect(errors.length, equals(2));
      expect(errors[0], contains('index 1'));
      expect(errors[1], contains('index 3'));

      // Reset error handler
      Parsable.setOnParseError((message) {});
    });

    test('should return empty list when value is not a List', () {
      final errors = <String>[];
      Parsable.setOnParseError((message) {
        errors.add(message);
      });

      final user = TestUserWithAddress.fromMap({
        'addresses': 'not a list', // wrong type
      });

      expect(user.addresses, isEmpty);
      expect(errors.length, equals(1));
      expect(
        errors[0],
        contains('Unable to parse property "addresses" as List'),
      );

      // Reset error handler
      Parsable.setOnParseError((message) {});
    });

    test('should handle parsing errors gracefully', () {
      final errors = <String>[];
      Parsable.setOnParseError((message) {
        errors.add(message);
      });

      // Create data that will cause parsing to fail in fromMap
      final user = TestUserWithAddress.fromMap({
        'addresses': [
          {'street': '123 Main St', 'city': 'Springfield'}, // valid
          {}, // valid map but might have issues in model
        ],
      });

      // Should have parsed the valid ones
      expect(user.addresses.length, greaterThanOrEqualTo(1));

      // Reset error handler
      Parsable.setOnParseError((message) {});
    });
  });
}
