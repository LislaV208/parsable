// ignore_for_file: avoid_print

import 'package:parsable/parsable.dart';

// Basic model example
class User extends Parsable {
  const User({required super.data});

  String? get name => get('name');
  int? get age => get('age');
  String? get email => get('email');
  bool? get isActive => get('isActive');

  factory User.fromMap(Map<String, dynamic> map) => User(data: map);
}

// Example with default values
class Product extends Parsable {
  const Product({required super.data});

  String get id => get('id') ?? '';
  String get name => get('name') ?? 'Unknown Product';
  double get price => get('price') ?? 0.0;
  int get quantity => get('quantity') ?? 0;
  bool get inStock => get('inStock') ?? false;

  factory Product.fromMap(Map<String, dynamic> map) => Product(data: map);
}

// Nested objects example
class Address extends Parsable {
  const Address({required super.data});

  String? get street => get('street');
  String? get city => get('city');
  String? get zipCode => get('zipCode');
  String? get country => get('country');

  factory Address.fromMap(Map<String, dynamic> map) => Address(data: map);
}

class Customer extends Parsable {
  const Customer({required super.data});

  String? get name => get('name');
  String? get phone => get('phone');
  Address? get shippingAddress =>
      get('shippingAddress', parser: Address.fromMap);
  Address? get billingAddress => get('billingAddress', parser: Address.fromMap);

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(data: map);
}

void main() {
  print('=== Parsable Examples ===\n');

  // Example 1: Basic usage
  print('1. Basic Usage:');
  final userData = {
    'name': 'John Doe',
    'age': 30,
    'email': 'john@example.com',
    'isActive': true,
  };

  final user = User.fromMap(userData);
  print('   Name: ${user.name}');
  print('   Age: ${user.age}');
  print('   Email: ${user.email}');
  print('   Active: ${user.isActive}');
  print('');

  // Example 2: Handling missing data
  print('2. Handling Missing Data:');
  final incompleteData = {
    'name': 'Jane Smith',
    'age': 25,
    // email and isActive are missing
  };

  final incompleteUser = User.fromMap(incompleteData);
  print('   Name: ${incompleteUser.name}');
  print('   Age: ${incompleteUser.age}');
  print('   Email: ${incompleteUser.email ?? 'Not provided'}');
  print('   Active: ${incompleteUser.isActive ?? false}');
  print('');

  // Example 3: Default values
  print('3. Default Values:');
  final productData = {
    'id': 'P123',
    'name': 'Laptop',
    'price': 999.99,
    // quantity and inStock not provided
  };

  final product = Product.fromMap(productData);
  print('   ID: ${product.id}');
  print('   Name: ${product.name}');
  print('   Price: \$${product.price}');
  print('   Quantity: ${product.quantity} (default)');
  print('   In Stock: ${product.inStock} (default)');
  print('');

  // Example 4: Completely empty product
  print('4. Empty Data with Defaults:');
  final emptyProduct = Product.fromMap({});
  print('   ID: "${emptyProduct.id}"');
  print('   Name: ${emptyProduct.name}');
  print('   Price: \$${emptyProduct.price}');
  print('');

  // Example 5: Nested objects
  print('5. Nested Objects:');
  final customerData = {
    'name': 'Alice Johnson',
    'phone': '+1-555-0123',
    'shippingAddress': {
      'street': '123 Main St',
      'city': 'Springfield',
      'zipCode': '12345',
      'country': 'USA',
    },
    'billingAddress': {
      'street': '456 Oak Ave',
      'city': 'Shelbyville',
      'zipCode': '67890',
      'country': 'USA',
    },
  };

  final customer = Customer.fromMap(customerData);
  print('   Customer: ${customer.name}');
  print('   Phone: ${customer.phone}');
  print(
    '   Shipping: ${customer.shippingAddress?.street}, ${customer.shippingAddress?.city}',
  );
  print(
    '   Billing: ${customer.billingAddress?.street}, ${customer.billingAddress?.city}',
  );
  print('');

  // Example 6: Numeric conversions
  print('6. Automatic Numeric Conversions:');
  final mixedNumberData = {
    'intAsDouble': 42, // int will be converted to double
    'doubleAsInt': 99.7, // double will be truncated to int
  };

  // Create a temporary model to show conversions
  final tempData = mixedNumberData;
  final intValue = tempData['intAsDouble'] as int;
  final doubleValue = tempData['doubleAsInt'] as double;

  print('   Original int value: $intValue (type: ${intValue.runtimeType})');
  print('   As double: ${intValue.toDouble()} (automatic conversion)');
  print(
    '   Original double value: $doubleValue (type: ${doubleValue.runtimeType})',
  );
  print('   As int: ${doubleValue.toInt()} (truncated)');
  print('');

  // Example 7: Equality comparison
  print('7. Equality Comparison (via Equatable):');
  final user1 = User.fromMap({'name': 'Bob', 'age': 35});
  final user2 = User.fromMap({'name': 'Bob', 'age': 35});
  final user3 = User.fromMap({'name': 'Charlie', 'age': 40});

  print('   user1 == user2: ${user1 == user2} (same data)');
  print('   user1 == user3: ${user1 == user3} (different data)');
  print('');

  // Example 8: Convert back to Map
  print('8. Converting Back to Map:');
  final originalMap = {'name': 'Dave', 'age': 45};
  final userFromMap = User.fromMap(originalMap);
  final convertedBack = userFromMap.toMap();

  print('   Original map: $originalMap');
  print('   Converted back: $convertedBack');
  print('   Maps are identical: ${identical(originalMap, convertedBack)}');
  print('');

  print('=== Examples Complete ===');
}
