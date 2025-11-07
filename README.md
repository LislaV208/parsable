# Parsable

[![pub package](https://img.shields.io/pub/v/parsable.svg)](https://pub.dev/packages/parsable)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Type-safe map parsing for Dart. Simplifies extracting values from `Map<String, dynamic>` with automatic type conversion and nested object support.

## Features

- **Type-safe value extraction** - Get values with compile-time type safety
- **Custom type parsing** - Parse any type with custom parser functions (String → DateTime, int, enums, etc.)
- **Automatic type conversions** - Seamless `int` ↔ `double` conversions
- **Nested object support** - Parse complex object hierarchies with ease
- **List parsing** - Easy parsing of lists with `getList()` method
- **Equatable integration** - Built-in value equality comparison
- **Configurable error handling** - Customize how parsing errors are handled
- **Null safety** - Full null safety support out of the box
- **Zero boilerplate** - Clean, readable model definitions

## Installation

Add `parsable` to your `pubspec.yaml`:

```yaml
dependencies:
  parsable: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Usage

### Basic Example

Create a model by extending `Parsable` and define getters using the `get<T>()` method:

```dart
import 'package:parsable/parsable.dart';

class User extends Parsable {
  const User({required super.data});

  String? get name => get('name');
  int? get age => get('age');
  String? get email => get('email');
  bool? get isActive => get('isActive');

  factory User.fromMap(Map<String, dynamic> map) => User(data: map);
}

void main() {
  final userData = {
    'name': 'Alice',
    'age': 28,
    'email': 'alice@example.com',
    'isActive': true,
  };

  final user = User.fromMap(userData);
  print(user.name); // Alice
  print(user.age); // 28
  print(user.isActive); // true
}
```

### Default Values

Use the null-aware operator `??` to provide default values:

```dart
class User extends Parsable {
  const User({required super.data});

  String get name => get('name') ?? 'Unknown';
  int get age => get('age') ?? 0;
  bool get isActive => get('isActive') ?? false;

  factory User.fromMap(Map<String, dynamic> map) => User(data: map);
}
```

### Nested Objects

Parse nested objects by providing a parser function:

```dart
class Address extends Parsable {
  const Address({required super.data});

  String? get street => get('street');
  String? get city => get('city');
  String? get zipCode => get('zipCode');
  String? get country => get('country');

  factory Address.fromMap(Map<String, dynamic> map) => Address(data: map);
}

class User extends Parsable {
  const User({required super.data});

  String? get name => get('name');
  int? get age => get('age');
  Address? get address => get('address', parser: Address.fromMap);

  factory User.fromMap(Map<String, dynamic> map) => User(data: map);
}

void main() {
  final userData = {
    'name': 'Bob',
    'age': 35,
    'address': {
      'street': '123 Main St',
      'city': 'Springfield',
      'zipCode': '12345',
      'country': 'USA',
    },
  };

  final user = User.fromMap(userData);
  print(user.name); // Bob
  print(user.address?.city); // Springfield
  print(user.address?.zipCode); // 12345
}
```

### Parsing Lists

Parse lists of objects using the `getList()` method:

```dart
class Comment extends Parsable {
  const Comment({required super.data});

  String? get author => get('author');
  String? get text => get('text');

  factory Comment.fromMap(Map<String, dynamic> map) => Comment(data: map);
}

class Post extends Parsable {
  const Post({required super.data});

  String? get title => get('title');
  String? get content => get('content');

  // Parse list of comments with getList
  List<Comment> get comments => getList('comments', parser: Comment.fromMap) ?? [];

  factory Post.fromMap(Map<String, dynamic> map) => Post(data: map);
}

void main() {
  final postData = {
    'title': 'Hello World',
    'content': 'This is my first post',
    'comments': [
      {'author': 'Alice', 'text': 'Great post!'},
      {'author': 'Bob', 'text': 'Thanks for sharing!'},
    ],
  };

  final post = Post.fromMap(postData);
  print(post.title); // Hello World
  print(post.comments.length); // 2
  print(post.comments[0].author); // Alice
}
```

### Custom Type Parsing

Parse any type using custom parser functions. Thanks to Dart's type inference, you don't need to explicitly specify type parameters:

```dart
class Event extends Parsable {
  const Event({required super.data});

  String? get name => get('name');

  // Parse String to DateTime
  DateTime? get startDate => get('startDate',
    parser: (String val) => DateTime.parse(val)
  );

  // Parse String to int
  int? get attendeeCount => get('attendeeCount',
    parser: (String val) => int.parse(val)
  );

  // Parse String to custom enum
  EventStatus get status => get('status',
    parser: (String val) => EventStatus.fromString(val)
  ) ?? EventStatus.pending;

  // Parse list of date strings to list of DateTime objects
  List<DateTime> get eventDates => getList('eventDates',
    parser: (String val) => DateTime.parse(val)
  ) ?? [];

  factory Event.fromMap(Map<String, dynamic> map) => Event(data: map);
}

enum EventStatus {
  pending,
  confirmed,
  cancelled;

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventStatus.pending,
    );
  }
}

void main() {
  final eventData = {
    'name': 'Tech Conference 2024',
    'startDate': '2024-06-15T09:00:00Z',
    'attendeeCount': '150',
    'status': 'confirmed',
    'eventDates': [
      '2024-06-15T09:00:00Z',
      '2024-06-16T09:00:00Z',
      '2024-06-17T09:00:00Z',
    ],
  };

  final event = Event.fromMap(eventData);
  print(event.name); // Tech Conference 2024
  print(event.startDate); // 2024-06-15 09:00:00.000Z
  print(event.attendeeCount); // 150
  print(event.status); // EventStatus.confirmed
  print(event.eventDates.length); // 3
}
```

The parser function receives the exact type you specify (e.g., `String`) and the compiler ensures type safety at compile time. If the value in the map doesn't match the expected type, an error will be logged and `null` will be returned.

### Complex Example with Multiple Nested Objects

```dart
class Product extends Parsable {
  const Product({required super.data});

  String? get id => get('id');
  String? get name => get('name');
  double? get price => get('price');

  factory Product.fromMap(Map<String, dynamic> map) => Product(data: map);
}

class OrderItem extends Parsable {
  const OrderItem({required super.data});

  Product? get product => get('product', parser: Product.fromMap);
  int? get quantity => get('quantity');

  double? get total => (product?.price ?? 0) * (quantity ?? 0);

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(data: map);
}

class Order extends Parsable {
  const Order({required super.data});

  String? get orderId => get('orderId');

  // Parse ISO 8601 date string to DateTime
  DateTime? get orderDate => get('orderDate',
    parser: (String val) => DateTime.parse(val)
  );

  Address? get shippingAddress => get('shippingAddress', parser: Address.fromMap);
  List<OrderItem> get items => getList('items', parser: OrderItem.fromMap) ?? [];

  factory Order.fromMap(Map<String, dynamic> map) => Order(data: map);
}
```

### Automatic Numeric Conversions

By default, `parsable` automatically converts between `int` and `double`:

```dart
final data = {'count': 42}; // int value
final obj = MyParsable(data: data);

double? value = obj.get('count'); // Returns 42.0 (automatic int→double conversion)
```

To disable this behavior:

```dart
Parsable.handleNumericConversions(false);
```

### Custom Error Handling

Customize how parsing errors are handled:

```dart
// Throw exceptions on errors
Parsable.setOnParseError((message) {
  throw FormatException(message);
});

// Use a custom logger
Parsable.setOnParseError((message) {
  myLogger.error(message);
});

// Silent mode (ignore errors)
Parsable.setOnParseError((message) {});
```

### Equatable Integration

All `Parsable` objects automatically support value equality:

```dart
final user1 = User.fromMap({'name': 'Alice', 'age': 28});
final user2 = User.fromMap({'name': 'Alice', 'age': 28});
final user3 = User.fromMap({'name': 'Bob', 'age': 30});

print(user1 == user2); // true
print(user1 == user3); // false
```

### Converting Back to Map

```dart
final user = User.fromMap({'name': 'Alice', 'age': 28});
final map = user.toMap(); // Returns the original Map<String, dynamic>
```

## Common Use Cases

### JSON API Responses

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiUser extends Parsable {
  const ApiUser({required super.data});

  String? get id => get('id');
  String? get username => get('username');
  String? get email => get('email');

  factory ApiUser.fromMap(Map<String, dynamic> map) => ApiUser(data: map);
}

Future<ApiUser> fetchUser(String userId) async {
  final response = await http.get(Uri.parse('https://api.example.com/users/$userId'));
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return ApiUser.fromMap(json);
}
```

### Configuration Files

```dart
class AppConfig extends Parsable {
  const AppConfig({required super.data});

  String get apiUrl => get('apiUrl') ?? 'https://api.example.com';
  int get timeout => get('timeout') ?? 30;
  bool get enableLogging => get('enableLogging') ?? false;
  String? get apiKey => get('apiKey');

  factory AppConfig.fromMap(Map<String, dynamic> map) => AppConfig(data: map);
}
```

### Local Storage / SharedPreferences

```dart
class UserPreferences extends Parsable {
  const UserPreferences({required super.data});

  String get theme => get('theme') ?? 'light';
  String get language => get('language') ?? 'en';
  bool get notificationsEnabled => get('notificationsEnabled') ?? true;

  factory UserPreferences.fromMap(Map<String, dynamic> map) =>
      UserPreferences(data: map);
}
```

## Why Parsable?

Traditional approaches to parsing maps in Dart often involve:
- Manual null checking for every field
- Verbose casting: `data['name'] as String?`
- Repetitive error handling
- Difficult nested object parsing

**Parsable** eliminates this boilerplate while providing:
- Clean, readable code
- Type safety
- Automatic type conversions
- Easy nested object handling
- Consistent error handling

## Additional Information

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

If you encounter any issues or have feature requests, please file them in the [issue tracker](https://github.com/LislaV208/parsable/issues).

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
