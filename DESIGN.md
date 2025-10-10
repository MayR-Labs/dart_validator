# DESIGN.md

## MayrValidations — Design Document

### Overview

**MayrValidations** is a lightweight, chainable, and expressive validation framework written in pure Dart.
It provides a fluent API for defining validation logic in a declarative, composable manner — heavily inspired by Laravel’s validation system but designed for Dart’s ergonomics.

The architecture separates:

* **`MayrValidator`** — the per-value validator, instantiated per input.
* **`MayrValidationCore`** — the global singleton registry that manages configuration, messages, defaults, and custom/group rules.

---

## 1. Core Philosophy

1. **Readable** – Validation chains should read like English logic:

   ```dart
   value.mayrValidator().required().min(3).max(256).run();
   ```
2. **Reusable** – Rules, messages, and groups are globally registered once and used everywhere.
3. **Lightweight** – Core runs on pure Dart; Flutter wrappers come later.
4. **Predictable** – Consistent validation flow, first-error return, optional debounce.
5. **Composable** – Supports custom rules and grouped rule sets.

---

## 2. Core Architecture

### 2.1 `MayrValidator`

* Represents an individual validator instance tied to a single input value.
* Holds a local list of validation rules to execute.
* Delegates configuration lookups and registrations to `MayrValidationCore`.

Example:

```dart
MayrValidator(value)
  .required()
  .min(2)
  .max(256)
  .run();
```

or via extension:

```dart
value.mayrValidator()
  .required()
  .min(2)
  .run();
```

---

### 2.2 `MayrValidationCore` (Singleton)

The global configuration manager and registry.

#### Responsibilities

* Holds global configuration (`messages`, `defaults`).
* Registers and exposes custom validation rules.
* Registers and exposes validation groups.
* Handles environment-aware behavior (dev vs prod).
* Exposes a static `instance` for global access.

Implementation sketch:

```dart
class MayrValidationCore {
  static final MayrValidationCore _instance = MayrValidationCore._internal();
  factory MayrValidationCore() => _instance;
  MayrValidationCore._internal();

  final Map<String, Function> _customRules = {};
  final Map<String, Function> _groups = {};
  final Map<String, dynamic> _config = {};

  void setup(Map<String, dynamic> config) { ... }
  void register(String name, Function rule) { ... }
  void registerGroup(String name, Function group) { ... }

  Map<String, dynamic> get config => _config;
}
```

All `MayrValidator` instances internally query this core:

```dart
final core = MayrValidationCore();
```

---

## 3. Primary API

### 3.1 Global Setup

```dart
MayrValidationCore().setup({
  'messages': {
    'required': 'This field is required',
    'min': 'Must be at least {min} characters',
    'max': 'Must not exceed {max} characters',
    'email': 'Please enter a valid email',
  },
  'defaults': {
    'min': 3,
    'max': 255,
  },
});
```

* `messages`: maps rule names to default error messages.
* `defaults`: defines default params for rules like `min()` or `max()`.
* `setup()` merges with existing configuration.

---

### 3.2 Instance-Based Validation

#### Example:

```dart
validator: (value) => MayrValidator(value)
  .required()
  .min(2)
  .max(256)
  .custom('userId')
  .run(debounce: Duration(milliseconds: 200));
```

#### Key Methods

| Method                                                 | Description                                        |
| ------------------------------------------------------ | -------------------------------------------------- |
| `.required([String? message])`                         | Checks that the value is not null or empty.        |
| `.min(int minLength, [String? message])`               | Ensures minimum string length.                     |
| `.max(int maxLength, [String? message])`               | Ensures maximum string length.                     |
| `.email([String? message])`                            | Basic email format check.                          |
| `.custom(String name, [Map<String, dynamic>? params])` | Runs a registered custom rule.                     |
| `.group(String name, [Map<String, dynamic>? params])`  | Runs a group of rules.                             |
| `.run({Duration debounce = Duration.zero})`            | Executes the chain, returns first error or `null`. |

---

## 4. Custom Rules & Groups

### 4.1 Register Custom Rule

```dart
MayrValidationCore().registerRule('userId', (String? value, Map<String, dynamic>? params) {
  if (value == null || value.isEmpty) return 'User ID is required';
  if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) return 'Invalid user ID';
  return null;
});
```

Then use it:

```dart
MayrValidator(value).custom('userId').run();
```

Behavior:

* In **dev**, unregistered custom rules throw.
* In **prod**, they’re ignored silently.

---

### 4.2 Register Group

```dart
MayrValidationCore().registerGroup('username', (validator, params) {
  return validator.required().min(3).max(20);
});
```

Usage:

```dart
MayrValidator(value).group('username').run();
```

Groups can compose multiple validations but should **not** call `.run()` inside themselves.

---

## 5. Execution Flow

1. Each validation call adds a rule to the validator’s internal `_rules` list.
2. `.run()` executes them in order.
3. If any rule returns a message (non-null), execution stops and that message is returned.
4. If all pass, `null` is returned.
5. `debounce` delays execution if set.

---

## 6. Error Handling

| Environment     | Behavior                                           |
| --------------- | -------------------------------------------------- |
| **Development** | Throws descriptive errors for missing rules/groups |
| **Production**  | Ignores unregistered ones silently                 |

This split ensures safe production behavior while retaining strict dev debugging.

---

## 7. Validation Helpers

MayrValidations ships with a comprehensive set of validation rules inspired by **Laravel’s Validator**, neatly grouped by type.
Each rule can be chained fluently and combined with custom logic to fit your needs.

---

### 🟩 **Booleans**

| Rule         | Description                                             |
| ------------ | ------------------------------------------------------- |
| `accepted()` | Must be accepted (e.g., “true”, “yes”, “1”).            |
| `boolean()`  | Must be a boolean value.                                |
| `declined()` | Must be explicitly declined (e.g., “false”, “no”, “0”). |

---

### 🧵 **Strings**

| Rule                                | Description                                            |
| ----------------------------------- | ------------------------------------------------------ |
| `activeUrl()`                       | Must be a valid and reachable URL.                     |
| `alpha()`                           | May contain only alphabetic characters.                |
| `alphaDash()`                       | May contain letters, numbers, dashes, and underscores. |
| `alphaNum()`                        | May contain only alphanumeric characters.              |
| `ascii()`                           | Must contain only ASCII characters.                    |
| `different(String otherValue)`      | Must differ from another value.                        |
| `doesntStartWith(String substring)` | Must not start with the given substring.               |
| `doesntEndWith(String substring)`   | Must not end with the given substring.                 |
| `email()`                           | Must be a valid email address.                         |
| `endsWith(String substring)`        | Must end with the given substring.                     |
| `hexColor()`                        | Must be a valid hex color (e.g. `#FF5733`).            |
| `in(List values)`                   | Must be one of the provided values.                    |
| `ipAddress()`                       | Must be a valid IP (IPv4 or IPv6).                     |
| `json()`                            | Must be a valid JSON string.                           |
| `lowercase()`                       | Must be entirely lowercase.                            |
| `macAddress()`                      | Must be a valid MAC address.                           |
| `max(int length)`                   | Must not exceed the given length.                      |
| `min(int length)`                   | Must have at least the given length.                   |
| `notIn(List values)`                | Must not be one of the provided values.                |
| `regex(String pattern)`             | Must match the given regular expression.               |
| `notRegex(String pattern)`          | Must not match the given regular expression.           |
| `same(String otherValue)`           | Must match another field’s value.                      |
| `size(int length)`                  | Must be exactly the specified length.                  |
| `startsWith(String substring)`      | Must start with the given substring.                   |
| `string()`                          | Must be a valid string.                                |
| `uppercase()`                       | Must be entirely uppercase.                            |
| `url()`                             | Must be a valid URL.                                   |
| `ulid()`                            | Must be a valid ULID string.                           |
| `uuid()`                            | Must be a valid UUID string.                           |

---

### 🔢 **Numbers**

| Rule                              | Description                                       |
| --------------------------------- | ------------------------------------------------- |
| `between(num min, num max)`       | Must be between the given range.                  |
| `decimal()`                       | Must be a valid decimal number.                   |
| `different(num otherValue)`       | Must differ from another number.                  |
| `digits(int count)`               | Must have exactly the specified number of digits. |
| `digitsBetween(int min, int max)` | Must have a number of digits between min and max. |
| `gt(num value)`                   | Must be greater than the given value.             |
| `gte(num value)`                  | Must be greater than or equal to the given value. |
| `integer()`                       | Must be an integer.                               |
| `lt(num value)`                   | Must be less than the given value.                |
| `lte(num value)`                  | Must be less than or equal to the given value.    |
| `max(num value)`                  | Must not exceed the given number.                 |
| `maxDigits(int count)`            | Must not exceed the given number of digits.       |
| `min(num value)`                  | Must be at least the given number.                |
| `minDigits(int count)`            | Must have at least the given number of digits.    |
| `multipleOf(num value)`           | Must be a multiple of the given number.           |
| `numeric()`                       | Must be numeric.                                  |
| `same(num otherValue)`            | Must match another numeric value.                 |
| `size(num value)`                 | Must be exactly equal to the given value.         |

---

### 📦 **Arrays**

| Rule                           | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| `array()`                      | Must be a valid list or array.                   |
| `between(int min, int max)`    | Array length must be between min and max.        |
| `contains(dynamic value)`      | Must contain the specified value.                |
| `doesntContain(dynamic value)` | Must not contain the specified value.            |
| `distinct()`                   | All array elements must be unique.               |
| `inArray(List values)`         | Must contain only allowed values.                |
| `inArrayKeys(List keys)`       | Must contain only allowed keys.                  |
| `list()`                       | Must be a list of items (alias for `array()`).   |
| `max(int length)`              | Must not exceed the given length.                |
| `min(int length)`              | Must contain at least the given number of items. |
| `size(int length)`             | Must contain exactly the given number of items.  |

---

### 📅 **Dates**

| Rule                           | Description                                     |
| ------------------------------ | ----------------------------------------------- |
| `after(DateTime date)`         | Must be after the given date.                   |
| `afterOrEqual(DateTime date)`  | Must be after or equal to the given date.       |
| `before(DateTime date)`        | Must be before the given date.                  |
| `beforeOrEqual(DateTime date)` | Must be before or equal to the given date.      |
| `date()`                       | Must be a valid date string or DateTime object. |
| `dateEquals(DateTime date)`    | Must be equal to the given date.                |
| `dateFormat(String format)`    | Must match the given date format.               |
| `different(DateTime other)`    | Must differ from another date.                  |
| `timezone()`                   | Must be a valid timezone identifier.            |

---

### 🖼️ **Files**

| Rule                                    | Description                                   |
| --------------------------------------- | --------------------------------------------- |
| `between(int minKb, int maxKb)`         | File size must be within the given KB range.  |
| `dimensions({int? width, int? height})` | Must match given image dimensions.            |
| `extensions(List<String> allowed)`      | Must have one of the allowed file extensions. |
| `file()`                                | Must be a valid file.                         |
| `image()`                               | Must be a valid image file.                   |
| `max(int kb)`                           | Must not exceed the given file size in KB.    |
| `mimeTypes(List<String> types)`         | Must have one of the allowed MIME types.      |
| `mimeTypeByExtension()`                 | Validate MIME type based on file extension.   |
| `size(int kb)`                          | Must be exactly the given file size in KB.    |

---

### 🧰 **Utilities**

| Rule                             | Description                             |
| -------------------------------- | --------------------------------------- |
| `nullable()`                     | Allows null or empty values.            |
| `required()`                     | Field must not be null or empty.        |
| `requiredIf(bool condition)`     | Required only if the condition is true. |
| `requiredUnless(bool condition)` | Required unless the condition is true.  |
| `requiredArrayKeys(List keys)`   | The given keys must exist in the array. |

---

## 8. Example Usage

```dart
MayrValidationCore().setup({
  'messages': {
    'required': 'You must fill this field',
    'min': 'Too short! (min: {min})',
  },
  'defaults': {
    'min': 3,
  },
});

final result = MayrValidator(value)
    .required()
    .min(5)
    .group('username')
    .custom('userId')
    .run();

if (result != null) {
  print(result); // e.g. "Too short! (min: 5)"
}
```

---
