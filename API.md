# MayrValidations API Documentation

Complete API reference for MayrValidations v1.0.0

## Table of Contents

- [MayrValidationCore](#mayrvalidationcore)
- [MayrValidator](#mayrvalidator)
- [Validation Rules](#validation-rules)
  - [Utility Validators](#utility-validators)
  - [String Validators](#string-validators)
  - [Number Validators](#number-validators)
  - [Boolean Validators](#boolean-validators)
  - [Array Validators](#array-validators)
  - [Date Validators](#date-validators)
- [Extension Methods](#extension-methods)

---

## MayrValidationCore

The global singleton class for managing validation configuration.

### Methods

#### `setup(Map<String, dynamic> config)`

Configure global validation settings.

```dart
MayrValidationCore().setup({
  'messages': {
    'required': 'This field is required',
    'min': 'Must be at least {min} characters',
  },
  'defaults': {
    'min': 3,
    'max': 255,
  },
});
```

#### `registerRule(String name, Function rule)`

Register a custom validation rule.

```dart
MayrValidationCore().registerRule('userId', (String? value, Map<String, dynamic>? params) {
  if (value == null || value.isEmpty) return 'User ID is required';
  if (!RegExp(r'^USR_[A-Z0-9]+$').hasMatch(value)) return 'Invalid user ID';
  return null;
});
```

#### `registerGroup(String name, Function group)`

Register a validation group.

```dart
MayrValidationCore().registerGroup('username', (validator, params) {
  return validator.required().min(3).max(20).alphaDash();
});
```

#### `getMessage(String ruleName)`

Get a message template from configuration.

#### `getDefault(String key)`

Get a default value from configuration.

#### `reset()`

Reset all configuration (useful for testing).

---

## MayrValidator

The main validator class for chainable validation.

### Constructor

```dart
MayrValidator(dynamic value)
```

Creates a validator instance for the given value.

### Methods

#### `run({Duration debounce = Duration.zero})`

Execute all validation rules and return the first error or null.

```dart
final error = MayrValidator('test')
    .required()
    .min(5)
    .run();
```

#### `custom(String name, [Map<String, dynamic>? params])`

Execute a registered custom rule.

```dart
final error = MayrValidator('USR_123')
    .custom('userId')
    .run();
```

#### `group(String name, [Map<String, dynamic>? params])`

Execute a registered validation group.

```dart
final error = MayrValidator('john_doe')
    .group('username')
    .run();
```

---

## Validation Rules

### Utility Validators

#### `required([String? message])`

Field must not be null or empty.

```dart
MayrValidator(value).required().run()
MayrValidator(value).required('Custom error message').run()
```

#### `nullable()`

Allows null or empty values.

```dart
MayrValidator(value).nullable().email().run()
```

#### `requiredIf(bool condition, [String? message])`

Required only if condition is true.

```dart
MayrValidator(value).requiredIf(isRequired).run()
```

#### `requiredUnless(bool condition, [String? message])`

Required unless condition is true.

```dart
MayrValidator(value).requiredUnless(isOptional).run()
```

---

### String Validators

#### `string([String? message])`

Must be a valid string.

#### `min(int minLength, [String? message])`

Must have at least the given length.

```dart
MayrValidator('abc').min(3).run() // null (valid)
MayrValidator('ab').min(3).run()  // error
```

#### `max(int maxLength, [String? message])`

Must not exceed the given length.

```dart
MayrValidator('abc').max(5).run()  // null (valid)
MayrValidator('abcdef').max(5).run() // error
```

#### `size(int length, [String? message])`

Must be exactly the specified length.

```dart
MayrValidator('abc').size(3).run() // null (valid)
```

#### `email([String? message])`

Must be a valid email address.

```dart
MayrValidator('test@example.com').email().run() // null (valid)
MayrValidator('invalid').email().run() // error
```

#### `url([String? message])`

Must be a valid URL.

```dart
MayrValidator('https://example.com').url().run() // null (valid)
```

#### `alpha([String? message])`

May contain only alphabetic characters.

```dart
MayrValidator('abc').alpha().run() // null (valid)
MayrValidator('abc123').alpha().run() // error
```

#### `alphaNum([String? message])`

May contain only alphanumeric characters.

```dart
MayrValidator('abc123').alphaNum().run() // null (valid)
```

#### `alphaDash([String? message])`

May contain letters, numbers, dashes, and underscores.

```dart
MayrValidator('user_name-123').alphaDash().run() // null (valid)
```

#### `ascii([String? message])`

Must contain only ASCII characters.

#### `lowercase([String? message])`

Must be entirely lowercase.

```dart
MayrValidator('abc').lowercase().run() // null (valid)
MayrValidator('ABC').lowercase().run() // error
```

#### `uppercase([String? message])`

Must be entirely uppercase.

```dart
MayrValidator('ABC').uppercase().run() // null (valid)
```

#### `regex(String pattern, [String? message])`

Must match the given regular expression.

```dart
MayrValidator('abc123').regex(r'^[a-z0-9]+$').run() // null (valid)
```

#### `notRegex(String pattern, [String? message])`

Must not match the given regular expression.

```dart
MayrValidator('abc').notRegex(r'[0-9]').run() // null (valid)
```

#### `startsWith(String substring, [String? message])`

Must start with the given substring.

```dart
MayrValidator('hello world').startsWith('hello').run() // null (valid)
```

#### `endsWith(String substring, [String? message])`

Must end with the given substring.

```dart
MayrValidator('hello world').endsWith('world').run() // null (valid)
```

#### `doesntStartWith(String substring, [String? message])`

Must not start with the given substring.

#### `doesntEndWith(String substring, [String? message])`

Must not end with the given substring.

#### `inList(List values, [String? message])`

Must be one of the provided values.

```dart
MayrValidator('red').inList(['red', 'green', 'blue']).run() // null (valid)
```

#### `notIn(List values, [String? message])`

Must not be one of the provided values.

#### `same(dynamic otherValue, [String? message])`

Must match another field's value.

```dart
MayrValidator(password).same(confirmPassword).run()
```

#### `different(dynamic otherValue, [String? message])`

Must differ from another value.

#### `uuid([String? message])`

Must be a valid UUID string.

```dart
MayrValidator('550e8400-e29b-41d4-a716-446655440000').uuid().run() // null (valid)
```

#### `ulid([String? message])`

Must be a valid ULID string.

#### `ipAddress([String? message])`

Must be a valid IP address (IPv4 or IPv6).

```dart
MayrValidator('192.168.1.1').ipAddress().run() // null (valid)
```

#### `macAddress([String? message])`

Must be a valid MAC address.

```dart
MayrValidator('00:1B:44:11:3A:B7').macAddress().run() // null (valid)
```

#### `hexColor([String? message])`

Must be a valid hex color.

```dart
MayrValidator('#FF5733').hexColor().run() // null (valid)
```

#### `json([String? message])`

Must be a valid JSON string.

```dart
MayrValidator('{"key":"value"}').json().run() // null (valid)
```

---

### Number Validators

#### `numeric([String? message])`

Must be numeric.

```dart
MayrValidator(123).numeric().run() // null (valid)
MayrValidator('123').numeric().run() // null (valid)
```

#### `integer([String? message])`

Must be an integer.

```dart
MayrValidator(123).integer().run() // null (valid)
MayrValidator(123.45).integer().run() // error
```

#### `decimal([String? message])`

Must be a valid decimal number.

```dart
MayrValidator(123.45).decimal().run() // null (valid)
```

#### `between(num min, num max, [String? message])`

Must be between the given range.

```dart
MayrValidator(5).between(1, 10).run() // null (valid)
MayrValidator(15).between(1, 10).run() // error
```

#### `gt(num comparisonValue, [String? message])`

Must be greater than the given value.

```dart
MayrValidator(6).gt(5).run() // null (valid)
```

#### `gte(num comparisonValue, [String? message])`

Must be greater than or equal to the given value.

```dart
MayrValidator(5).gte(5).run() // null (valid)
```

#### `lt(num comparisonValue, [String? message])`

Must be less than the given value.

```dart
MayrValidator(4).lt(5).run() // null (valid)
```

#### `lte(num comparisonValue, [String? message])`

Must be less than or equal to the given value.

```dart
MayrValidator(5).lte(5).run() // null (valid)
```

#### `digits(int count, [String? message])`

Must have exactly the specified number of digits.

```dart
MayrValidator(123).digits(3).run() // null (valid)
```

#### `digitsBetween(int min, int max, [String? message])`

Must have a number of digits between min and max.

```dart
MayrValidator(123).digitsBetween(2, 4).run() // null (valid)
```

#### `multipleOf(num divisor, [String? message])`

Must be a multiple of the given number.

```dart
MayrValidator(10).multipleOf(5).run() // null (valid)
MayrValidator(11).multipleOf(5).run() // error
```

---

### Boolean Validators

#### `boolean([String? message])`

Must be a boolean value.

```dart
MayrValidator(true).boolean().run() // null (valid)
```

#### `accepted([String? message])`

Must be accepted (true, "yes", "1", 1, "on").

```dart
MayrValidator(true).accepted().run() // null (valid)
MayrValidator('yes').accepted().run() // null (valid)
```

#### `declined([String? message])`

Must be declined (false, "no", "0", 0, "off").

```dart
MayrValidator(false).declined().run() // null (valid)
MayrValidator('no').declined().run() // null (valid)
```

---

### Array Validators

#### `array([String? message])`

Must be a valid list or array.

```dart
MayrValidator([1, 2, 3]).array().run() // null (valid)
```

#### `contains(dynamic searchValue, [String? message])`

Must contain the specified value.

```dart
MayrValidator([1, 2, 3]).contains(2).run() // null (valid)
```

#### `doesntContain(dynamic searchValue, [String? message])`

Must not contain the specified value.

```dart
MayrValidator([1, 2, 3]).doesntContain(4).run() // null (valid)
```

#### `distinct([String? message])`

All array elements must be unique.

```dart
MayrValidator([1, 2, 3]).distinct().run() // null (valid)
MayrValidator([1, 2, 2]).distinct().run() // error
```

---

### Date Validators

#### `date([String? message])`

Must be a valid date.

```dart
MayrValidator(DateTime.now()).date().run() // null (valid)
MayrValidator('2023-01-01').date().run() // null (valid)
```

#### `after(DateTime comparisonDate, [String? message])`

Must be after the given date.

```dart
final tomorrow = DateTime.now().add(Duration(days: 1));
MayrValidator(tomorrow).after(DateTime.now()).run() // null (valid)
```

#### `afterOrEqual(DateTime comparisonDate, [String? message])`

Must be after or equal to the given date.

#### `before(DateTime comparisonDate, [String? message])`

Must be before the given date.

#### `beforeOrEqual(DateTime comparisonDate, [String? message])`

Must be before or equal to the given date.

#### `dateEquals(DateTime comparisonDate, [String? message])`

Must be equal to the given date.

---

## Extension Methods

### `String?.mayrValidator()`

Creates a MayrValidator instance for the string value.

```dart
final error = 'test@example.com'.mayrValidator()
    .required()
    .email()
    .run();
```

Works with nullable strings:

```dart
String? nullString;
final error = nullString.mayrValidator().required().run();
// Returns error message
```

---

## Complete Example

```dart
import 'package:mayr_validator/mayr_validator.dart';

void main() {
  // Setup global configuration
  MayrValidationCore().setup({
    'messages': {
      'required': 'This field is required',
      'min': 'Must be at least {min} characters',
      'email': 'Please enter a valid email',
    },
  });

  // Register custom rule
  MayrValidationCore().registerRule('userId', (value, params) {
    if (value == null || !value.startsWith('USR_')) {
      return 'Invalid user ID format';
    }
    return null;
  });

  // Register validation group
  MayrValidationCore().registerGroup('username', (validator, params) {
    return validator.required().min(3).max(20).alphaDash();
  });

  // Use in validation
  final error1 = 'test@example.com'.mayrValidator()
      .required()
      .email()
      .run();

  final error2 = 'john_doe'.mayrValidator()
      .group('username')
      .run();

  final error3 = 'USR_12345'.mayrValidator()
      .custom('userId')
      .run();

  print('Email: ${error1 ?? "Valid"}');
  print('Username: ${error2 ?? "Valid"}');
  print('User ID: ${error3 ?? "Valid"}');
}
```

---

## Message Template Placeholders

When configuring global messages, you can use these placeholders:

| Placeholder | Used In                              | Description              |
| ----------- | ------------------------------------ | ------------------------ |
| `{min}`     | `min()`, `between()`, `digitsBetween()` | Minimum value/length     |
| `{max}`     | `max()`, `between()`, `digitsBetween()` | Maximum value/length     |
| `{size}`    | `size()`, `digits()`                  | Expected size/length     |
| `{value}`   | `gt()`, `gte()`, `lt()`, `lte()`, `multipleOf()` | Comparison value |
| `{count}`   | `digits()`                            | Expected digit count     |
| `{substring}` | `startsWith()`, `endsWith()`        | Substring value          |

Example:

```dart
MayrValidationCore().setup({
  'messages': {
    'min': 'Must be at least {min} characters',
    'between': 'Must be between {min} and {max}',
  },
});
```
