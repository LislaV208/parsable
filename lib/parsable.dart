import 'dart:developer';

import 'package:equatable/equatable.dart';

/// A type alias for [Map<String, dynamic>], commonly used for JSON-like data structures.
typedef ParsableMap = Map<String, dynamic>;

/// A callback function type for handling parse errors.
///
/// This function is called when type conversion fails or when a nested object
/// is accessed without providing a parser function.
typedef OnParseError = void Function(String message);

/// Base class for creating type-safe models from [Map<String, dynamic>] data.
///
/// [Parsable] provides a convenient way to extract values from maps with
/// automatic type checking, type conversion, and support for nested objects.
/// It extends [Equatable] for easy value comparison.
///
/// ## Basic Usage
///
/// ```dart
/// class User extends Parsable {
///   const User({required super.data});
///
///   String? get name => get('name');
///   int? get age => get('age');
///
///   factory User.fromMap(Map<String, dynamic> map) => User(data: map);
/// }
///
/// final user = User.fromMap({'name': 'John', 'age': 30});
/// print(user.name); // John
/// print(user.age); // 30
/// ```
///
/// ## Nested Objects
///
/// ```dart
/// class Address extends Parsable {
///   const Address({required super.data});
///
///   String? get city => get('city');
///   String? get street => get('street');
///
///   factory Address.fromMap(Map<String, dynamic> map) => Address(data: map);
/// }
///
/// class User extends Parsable {
///   const User({required super.data});
///
///   String? get name => get('name');
///   Address? get address => get('address', parser: Address.fromMap);
///
///   factory User.fromMap(Map<String, dynamic> map) => User(data: map);
/// }
/// ```
///
/// See also:
/// - [get] for extracting values with type safety
/// - [setOnParseError] for customizing error handling
/// - [handleNumericConversions] for controlling automatic numeric type conversion
abstract class Parsable extends Equatable {
  final ParsableMap data;

  /// Creates a [Parsable] instance with the provided data map.
  ///
  /// The [data] parameter should contain the raw map data to be parsed.
  const Parsable({required this.data});

  static OnParseError _onParseError = (String message) {
    log(message);
  };

  /// Sets a custom error handler for parse errors.
  ///
  /// By default, parse errors are logged using [dart:developer]'s [log] function.
  /// You can override this behavior to handle errors differently, such as:
  /// - Throwing exceptions
  /// - Logging to a custom logging service
  /// - Collecting errors for later analysis
  /// - Silently ignoring errors
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Throw exceptions on parse errors
  /// Parsable.setOnParseError((message) {
  ///   throw FormatException(message);
  /// });
  ///
  /// // Use a custom logger
  /// Parsable.setOnParseError((message) {
  ///   myLogger.error(message);
  /// });
  ///
  /// // Silent mode (ignore errors)
  /// Parsable.setOnParseError((message) {});
  /// ```
  ///
  /// Returns the provided [onParseError] callback.
  static OnParseError setOnParseError(OnParseError onParseError) =>
      _onParseError = onParseError;

  static bool _handleNumericConversions = true;

  /// Configures automatic numeric type conversions.
  ///
  /// When enabled (default), the [get] method automatically converts between
  /// `int` and `double` types as needed. For example:
  /// - An `int` value can be retrieved as `double`
  /// - A `double` value can be retrieved as `int` (truncated)
  ///
  /// Disable this if you need strict type matching for numeric values.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // With conversions enabled (default)
  /// final map = {'count': 42};
  /// final obj = MyParsable(data: map);
  /// double? value = obj.get<double>('count'); // 42.0 ✓
  ///
  /// // With conversions disabled
  /// Parsable.handleNumericConversions(false);
  /// double? value = obj.get<double>('count'); // null (type mismatch)
  /// ```
  ///
  /// Returns the provided [value].
  static bool handleNumericConversions(bool value) =>
      _handleNumericConversions = value;

  @override
  List<Object?> get props =>
      data.entries.expand((entry) => [entry.key, entry.value]).toList();

  /// Converts this [Parsable] object back to a [Map<String, dynamic>].
  ///
  /// Returns the original data map that was used to construct this object.
  Map<String, dynamic> toMap() => data;

  /// Extracts a value from the data map with type safety and automatic conversions.
  ///
  /// This method retrieves a value associated with [name] from the underlying
  /// data map and attempts to cast it to type [T]. If the value doesn't match
  /// the expected type, an error is logged via [_onParseError] and `null` is returned.
  ///
  /// ## Parameters
  ///
  /// - [name]: The key to look up in the data map.
  /// - [parser]: Optional function to parse values of type [V] to type [T].
  ///   Thanks to type inference, you don't need to explicitly specify [T] and [V].
  ///
  /// ## Type Parameters
  ///
  /// - [T]: The target type you want to get
  /// - [V]: The source type that the parser accepts (inferred from parser function)
  ///
  /// ## Type Conversions
  ///
  /// - Automatic `int` ↔ `double` conversion when [handleNumericConversions] is enabled (default).
  /// - Custom parsing with [parser] function for any type conversions.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// // Simple types
  /// String? name = get('name');
  /// int? age = get('age');
  /// bool? active = get('active');
  ///
  /// // Nested objects (V inferred as Map<String, dynamic>)
  /// Address? address = get('address', parser: Address.fromMap);
  ///
  /// // Custom parsing (V inferred as String)
  /// DateTime? createdAt = get('createdAt',
  ///   parser: (String val) => DateTime.parse(val)
  /// );
  ///
  /// // With default values
  /// String name = get('name') ?? 'Unknown';
  /// int age = get('age') ?? 0;
  /// ```
  ///
  /// Returns `null` if:
  /// - The key doesn't exist in the data map
  /// - Type conversion fails
  /// - Parser throws an exception
  /// - Value type doesn't match expected parser input type [V]
  T? get<T, V>(String name, {T? Function(V value)? parser}) {
    var value = data[name];
    if (value == null) {
      return null;
    }

    // If parser is provided, try to use it
    if (parser != null) {
      try {
        if (value is V) {
          return parser(value);
        } else {
          _onParseError(
            '[$runtimeType] Failed to parse property "$name": expected value of type "$V", got "${value.runtimeType}"',
          );
          return null;
        }
      } catch (e) {
        _onParseError('[$runtimeType] Failed to parse property "$name": $e');
        return null;
      }
    }

    // If value is a map but no parser provided, this is an error
    // (nested objects should use parser functions)
    if (value is ParsableMap) {
      _onParseError(_buildErrorMessage<T>(name, value, noParser: true));
      return null;
    }

    // If no parser, continue with automatic conversions
    if (_handleNumericConversions && value is num) {
      if (T == double) {
        return value.toDouble() as T;
      } else if (T == int) {
        return value.toInt() as T;
      }
    }

    if (value is T) {
      return value;
    }

    _onParseError(_buildErrorMessage<T>(name, value));

    return null;
  }

  /// Extracts a list of values from the data map with type safety.
  ///
  /// This method retrieves a list associated with [name] from the underlying
  /// data map and parses each element using the provided [parser] function.
  ///
  /// ## Parameters
  ///
  /// - [name]: The key to look up in the data map.
  /// - [parser]: Function to parse each list element from type [V] to [T].
  ///
  /// ## Type Parameters
  ///
  /// - [T]: The target type for each list element
  /// - [V]: The source type that the parser accepts (inferred from parser function)
  ///
  /// ## Examples
  ///
  /// ```dart
  /// class Order extends Parsable {
  ///   const Order({required super.data});
  ///
  ///   // Parsing objects from maps (V inferred as Map<String, dynamic>)
  ///   List<OrderItem> get items => getList('items', parser: OrderItem.fromMap) ?? [];
  ///
  ///   // Parsing dates from strings (V inferred as String)
  ///   List<DateTime> get dates => getList('dates',
  ///     parser: (String val) => DateTime.parse(val)
  ///   ) ?? [];
  ///
  ///   factory Order.fromMap(Map<String, dynamic> map) => Order(data: map);
  /// }
  /// ```
  ///
  /// Returns `null` if:
  /// - The key doesn't exist in the data map
  /// - The value at the key is explicitly `null`
  ///
  /// Returns an empty list `[]` if:
  /// - The value is not a List (with error logged)
  /// - All items in the list failed to parse
  List<T>? getList<T, V>(String name, {required T Function(V value) parser}) {
    final value = data[name];

    if (value == null) {
      return null;
    }

    if (value is! List) {
      _onParseError(
        '[$runtimeType] Unable to parse property "$name" as List. Expected "List", got "${value.runtimeType}"',
      );
      return [];
    }

    final results = <T>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];

      if (item is V) {
        try {
          final parsed = parser(item);
          results.add(parsed);
        } catch (e) {
          _onParseError(
            '[$runtimeType] Failed to parse list item at index $i in "$name": $e',
          );
        }
      } else {
        _onParseError(
          '[$runtimeType] List item at index $i in "$name" has wrong type. Expected "$V", got "${item.runtimeType}"',
        );
      }
    }

    return results;
  }

  String _buildErrorMessage<T>(
    String name,
    dynamic value, {
    bool noParser = false,
  }) {
    return '[$runtimeType] Unable to parse property "$name" with value "$value". Expected "$T", got "${value.runtimeType}"${noParser ? ' - no parser provided' : ''}';
  }
}
