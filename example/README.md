# Parsable Examples

This directory contains examples demonstrating the various features and use cases of the Parsable package.

## Running the Examples

To run any example, use the Dart command:

```bash
# Basic examples
dart run example/parsable_example.dart

# Advanced examples
dart run example/advanced_example.dart
```

## Example Files

### `parsable_example.dart` - Basic Usage

This file demonstrates fundamental Parsable features:

1. **Basic Usage** - Creating a simple model and extracting values
2. **Handling Missing Data** - Working with incomplete data and null values
3. **Default Values** - Using the null-aware operator for default values
4. **Empty Data with Defaults** - Handling completely empty maps
5. **Nested Objects** - Parsing nested objects with parser functions
6. **Automatic Numeric Conversions** - Converting between int and double
7. **Equality Comparison** - Using Equatable for value comparison
8. **Converting Back to Map** - Using the `toMap()` method

**Best for:** Getting started with Parsable, understanding core concepts

### `advanced_example.dart` - Real-World Scenarios

This file shows more complex, production-ready examples:

1. **E-commerce Order with Multiple Nested Levels**
   - Complex domain models (Order, Product, Price, Shipping, Payment)
   - Multiple levels of nesting (Order → OrderItem → Product → Price)
   - List parsing for collections
   - Computed properties
   - DateTime parsing

2. **Custom Error Handling**
   - Setting up custom error handlers
   - Capturing and logging parse errors
   - Graceful fallbacks

3. **Strict Type Checking**
   - Disabling automatic numeric conversions
   - Strict type validation
   - Comparing behavior with and without conversions

4. **Equality with Complex Nested Objects**
   - Comparing objects with nested structures
   - Understanding how Equatable works with nested maps

5. **Partial Data and Null Safety**
   - Working with incomplete nested data
   - Safe navigation with null-aware operators
   - Default values for missing nested objects

**Best for:** Understanding production patterns, complex data structures, error handling

## Key Concepts Demonstrated

### 1. Basic Model Definition

```dart
class User extends Parsable {
  const User({required super.data});

  String? get name => get('name');
  int? get age => get('age');

  factory User.fromMap(Map<String, dynamic> map) => User(data: map);
}
```

### 2. Default Values

```dart
class Product extends Parsable {
  const Product({required super.data});

  String get name => get('name') ?? 'Unknown Product';
  double get price => get('price') ?? 0.0;

  factory Product.fromMap(Map<String, dynamic> map) => Product(data: map);
}
```

### 3. Nested Objects

```dart
class User extends Parsable {
  const User({required super.data});

  Address? get address => get('address', parser: Address.fromMap);

  factory User.fromMap(Map<String, dynamic> map) => User(data: map);
}
```

### 4. List Parsing

```dart
class Order extends Parsable {
  const Order({required super.data});

  List<OrderItem> get items {
    final itemsList = data['items'] as List?;
    return itemsList?.map((item) => OrderItem.fromMap(item)).toList() ?? [];
  }

  factory Order.fromMap(Map<String, dynamic> map) => Order(data: map);
}
```

### 5. Computed Properties

```dart
class OrderItem extends Parsable {
  const OrderItem({required super.data});

  Product? get product => get('product', parser: Product.fromMap);
  int get quantity => get('quantity') ?? 1;

  double get subtotal {
    final productPrice = product?.price?.amount ?? 0.0;
    return productPrice * quantity;
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(data: map);
}
```

### 6. DateTime Parsing

```dart
DateTime? get orderDate {
  final dateStr = get<String>('orderDate');
  return dateStr != null ? DateTime.tryParse(dateStr) : null;
}
```

## Common Patterns

### Pattern 1: API Response Model

Use Parsable to create models from JSON API responses:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<User> fetchUser(String id) async {
  final response = await http.get(Uri.parse('https://api.example.com/users/$id'));
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return User.fromMap(json);
}
```

### Pattern 2: Configuration Files

Parse configuration from JSON files:

```dart
class AppConfig extends Parsable {
  const AppConfig({required super.data});

  String get apiUrl => get('apiUrl') ?? 'https://api.example.com';
  int get timeout => get('timeout') ?? 30;
  bool get enableLogging => get('enableLogging') ?? true;

  factory AppConfig.fromMap(Map<String, dynamic> map) => AppConfig(data: map);
}
```

### Pattern 3: Form Data

Handle form data with optional fields:

```dart
class UserForm extends Parsable {
  const UserForm({required super.data});

  String? get firstName => get('firstName');
  String? get lastName => get('lastName');
  String? get email => get('email');

  bool get isValid =>
    firstName != null &&
    lastName != null &&
    email != null;

  factory UserForm.fromMap(Map<String, dynamic> map) => UserForm(data: map);
}
```

## Tips and Best Practices

1. **Always provide a `fromMap` factory constructor** for consistency
2. **Use nullable types (`?`) for optional fields** and non-nullable for required fields with defaults
3. **Leverage computed properties** for derived values
4. **Use the `??` operator** for default values
5. **Parse lists manually** in getters when needed
6. **Handle errors gracefully** with custom error handlers in production
7. **Use const constructors** when possible for better performance
8. **Consider disabling numeric conversions** if you need strict type checking

## Next Steps

- Read the [main README](../README.md) for complete API documentation
- Check out the [pub.dev page](https://pub.dev/packages/parsable) for the latest version
- Report issues or suggest features on [GitHub](https://github.com/LislaV208/parsable/issues)
