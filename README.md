![License](https://img.shields.io/badge/license-MIT-blue.svg?label=Licence)
![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)

![Pub Version](https://img.shields.io/pub/v/dart_validator?style=plastic&label=Version)
![Pub.dev Score](https://img.shields.io/pub/points/dart_validator?label=Score&style=plastic)
![Pub Likes](https://img.shields.io/pub/likes/dart_validator?label=Likes&style=plastic)
![Pub.dev Publisher](https://img.shields.io/pub/publisher/dart_validator?label=Publisher&style=plastic)
![Downloads](https://img.shields.io/pub/dm/dart_validator.svg?label=Downloads&style=plastic)

![Build Status](https://img.shields.io/github/actions/workflow/status/MayR-Labs/dart_validator/ci.yaml?label=Build)
![Issues](https://img.shields.io/github/issues/MayR-Labs/dart_validator.svg?label=Issues)
![Last Commit](https://img.shields.io/github/last-commit/MayR-Labs/dart_validator.svg?label=Latest%20Commit)
![Contributors](https://img.shields.io/github/contributors/MayR-Labs/dart_validator.svg?label=Contributors)


# 🧠 MayrValidations

**MayrValidations** is a powerful yet elegant validation library for Dart and Flutter, inspired by Laravel’s validator syntax and philosophy.
It provides a fluent API to build validations that are **expressive**, **chainable**, and **extensible**, without compromising flexibility.

---

## ✨ Features

* 🧩 **Fluent API** — Chain validation rules like Laravel.
* ⚙️ **Global Configuration** — Define global defaults and messages.
* 🔁 **Reusable Groups** — Register and reuse complex validation patterns.
* 🧱 **Custom Validators** — Extend the system with your own validation logic.
* ⚡ **Debounce Support** — Control when validations run (useful for live input validation).
* 🧍‍♂️ **Standalone or Flutter-ready** — Works in plain Dart and integrates perfectly with `TextFormField` in Flutter.

---

## 🚀 Installation

Add to your project:

```bash
dart pub add dart_validator
```

Or in `pubspec.yaml`:

```yaml
dependencies:
  dart_validator: ^1.0.0
```

---

## 🧩 Quick Start

### 🧠 Basic Usage in Dart

```dart
import 'package:mayr_validator/mayr_validator.dart';

void main() {
  // Basic validation
  final error = MayrValidator('test@example.com')
      .required()
      .email()
      .run();
  
  print(error); // null if valid, error message if invalid
}
```

### 📱 Flutter TextFormField Integration

```dart
import 'package:flutter/material.dart';
import 'package:mayr_validator/mayr_validator.dart';

TextFormField(
  decoration: InputDecoration(labelText: 'Email'),
  validator: (value) => value.mayrValidator()
      .required()
      .email()
      .max(100)
      .run(),
)
```

### 💡 More Flutter Examples

#### Registration Form

```dart
class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Configure global validation messages
    MayrValidationCore().setup({
      'messages': {
        'required': 'This field is required',
        'min': 'Must be at least {min} characters',
        'email': 'Please enter a valid email address',
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) => value.mayrValidator()
                .required()
                .email()
                .run(),
          ),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) => value.mayrValidator()
                .required()
                .min(8)
                .regex(r'(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])')
                .run(),
          ),
          
          // Confirm password field
          TextFormField(
            decoration: InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
            validator: (value) => value.mayrValidator()
                .required()
                .same(_passwordController.text, 'Passwords must match')
                .run(),
          ),
          
          // Submit button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Form is valid
                print('Form submitted!');
              }
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
```

---

## ⚙️ Global Configuration

Configure MayrValidations globally to set default messages and parameters.

```dart
void main() {
  // Setup global configuration
  MayrValidationCore().setup({
    'messages': {
      'required': 'This field is required',
      'min': 'Must be at least {min} characters',
      'max': 'Must not exceed {max} characters',
      'email': 'Please enter a valid email address',
    },
    'defaults': {
      'min': 3,
      'max': 255,
    },
  });
  
  runApp(MyApp());
}
```

### Message Placeholders

Use placeholders in your messages that will be replaced with actual values:

| Placeholder | Description                    | Example                            |
| ----------- | ------------------------------ | ---------------------------------- |
| `{min}`     | Minimum value/length           | "Must be at least {min} characters"|
| `{max}`     | Maximum value/length           | "Must not exceed {max} characters" |
| `{value}`   | Comparison value               | "Must be greater than {value}"     |
| `{size}`    | Expected size                  | "Must be exactly {size} characters"|

---

## ⚡ Running with Debounce

```dart
validator: (value) => MayrValidator(value)
    .required()
    .email()
    .run(debounce: Duration(milliseconds: 300));
```

If no `debounce` is passed, it defaults to `Duration.zero`.

---

## 🧱 Custom Validations

Register custom validation rules to extend the validation system with your own logic.

```dart
void main() {
  // Register a custom rule
  MayrValidationCore().registerRule('userId', (value, params) {
    if (value == null || value.isEmpty) {
      return 'User ID is required';
    }
    if (!value.startsWith('USR_')) {
      return 'User ID must start with USR_';
    }
    if (!RegExp(r'^USR_[A-Z0-9]+$').hasMatch(value)) {
      return 'Invalid user ID format';
    }
    return null; // null means valid
  });
}
```

Then use it in your validators:

```dart
// In a TextFormField
TextFormField(
  decoration: InputDecoration(labelText: 'User ID'),
  validator: (value) => value.mayrValidator()
      .required()
      .custom('userId')
      .run(),
)
```

### Environment-Aware Behavior

Custom rules behave differently based on the environment:

* **Development Mode**: Throws an exception if a custom rule is not registered
* **Production Mode**: Silently ignores unregistered custom rules

---

## 🧩 Validator Groups

Validator groups allow you to register reusable validation patterns for repeated logic.

```dart
void main() {
  // Register a group for username validation
  MayrValidationCore().registerGroup('username', (validator, params) {
    return validator
        .required()
        .min(3)
        .max(20)
        .alphaDash();
  });
  
  // Register a group for strong password validation
  MayrValidationCore().registerGroup('strongPassword', (validator, params) {
    return validator
        .required()
        .min(8)
        .regex(r'(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])');
  });
}
```

Use the group in your validators:

```dart
// In a TextFormField
TextFormField(
  decoration: InputDecoration(labelText: 'Username'),
  validator: (value) => value.mayrValidator()
      .group('username')
      .run(),
)

TextFormField(
  decoration: InputDecoration(labelText: 'Password'),
  obscureText: true,
  validator: (value) => value.mayrValidator()
      .group('strongPassword')
      .run(),
)
```

### Benefits of Groups

* ✅ **Reusable**: Define once, use everywhere
* ✅ **Maintainable**: Update validation logic in one place
* ✅ **Consistent**: Ensure same validation rules across your app
* ✅ **Clean Code**: Keep your validators concise and readable

---

## 🧰 Built-in Validation Helpers

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

## �� Design Overview

MayrValidations follows a clean architecture with separation of concerns:

* **`MayrValidationCore`** → Singleton core managing global setup, messages, defaults, custom rules, and validation groups
* **`MayrValidator`** → Instance-level builder handling chained validation logic for a single value
* **Extension `mayrValidator()`** → Enables the elegant `value.mayrValidator()` syntax

### Architecture Flow

1. **Setup** → Configure global messages and defaults via `MayrValidationCore().setup()`
2. **Register** → Register custom rules and groups via `registerRule()` and `registerGroup()`
3. **Validate** → Chain validation rules and call `.run()` to execute
4. **Result** → Returns `null` if valid, or an error message string if invalid

---

## 🧪 Example in Pure Dart

```dart
void main() {
  final validator = MayrValidator('HelloWorld')
      .required()
      .min(3)
      .max(12)
      .run();

  print(validator); // null if valid, else error message
}
```

---

## 📢 Additional Information

### 🤝 Contributing
Contributions are highly welcome!
If you have ideas for new extensions, improvements, or fixes, feel free to fork the repository and submit a pull request.

Please make sure to:
- Follow the existing coding style.
- Write tests for new features.
- Update documentation if necessary.

> Let's build something amazing together!

---

### 🐛 Reporting Issues
If you encounter a bug, unexpected behaviour, or have feature requests:
- Open an issue on the repository.
- Provide a clear description and steps to reproduce (if it's a bug).
- Suggest improvements if you have any ideas.

> Your feedback helps make the package better for everyone!

---

### 🧑‍💻 Author

**MayR Labs**

Crafting clean, reliable, and human-centric Flutter and Dart solutions.
🌍 [mayrlabs.com](https://mayrlabs.com)

---

### 📜 Licence
This package is licensed under the MIT License — which means you are free to use it for commercial and non-commercial projects, with proper attribution.

> See the [LICENSE](LICENSE) file for more details.

MIT © 2025 [MayR Labs](https://github.com/MayR-Labs)

---

## 🌟 Support

If you find this package helpful, please consider giving it a ⭐️ on GitHub — it motivates and helps the project grow!

You can also support by:
- Sharing the package with your friends, colleagues, and tech communities.
- Using it in your projects and giving feedback.
- Contributing new ideas, features, or improvements.

> Every little bit of support counts! 🚀💙
