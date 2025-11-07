## 0.2.0

* **BREAKING CHANGE**: Parser functions now use generic types for better type safety
  * `get<T>()` is now `get<T, V>()` where V is the source type
  * `getList<T>()` is now `getList<T, V>()` where V is the source type for each element
  * Thanks to type inference, you don't need to explicitly specify types in most cases
  * Example: `DateTime? date = get('date', parser: (String val) => DateTime.parse(val))`
* **Feature**: Parser functions now work with any type, not just maps
  * Parse strings to dates, ints, enums, or any custom type
  * Parse lists of non-map types (e.g., list of strings to list of DateTimes)
  * Compile-time type safety for parser input and output types
* **Bug Fix**: Added exception handling for parser functions in both `get<T, V>()` and `getList<T, V>()`
  * Parser exceptions are now caught and handled gracefully
  * Returns `null` (or skips item in lists) and triggers error handler when parser throws
* Improved error messages to show expected vs actual types
* Updated test suite to 46 tests (added 6 tests for generic parser functionality)

## 0.1.0

* Initial release of Parsable
* Type-safe map parsing with generic `get<T>()` method
* **List parsing with `getList<T>()` method** - easily parse lists of objects
* Automatic numeric type conversions (int ↔ double)
* Support for nested objects with parser functions
* Integration with Equatable for value equality
* Configurable error handling via `setOnParseError()`
* Ability to toggle numeric conversions with `handleNumericConversions()`
* Full null safety support
* Comprehensive documentation and examples
* 39 unit tests with 100% passing rate
