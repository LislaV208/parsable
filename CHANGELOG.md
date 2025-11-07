## 0.1.1

* **Bug Fix**: Added exception handling for parser functions in `get<T>()` method
  * Parser exceptions are now caught and handled gracefully
  * Returns `null` and triggers error handler when parser throws an exception
  * Consistent behavior with `getList<T>()` which already had exception handling
* Updated test suite to 40 tests (added parser exception handling test)

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
