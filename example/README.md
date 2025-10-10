# MayrValidator Examples

This directory contains examples demonstrating how to use MayrValidator in various scenarios.

## Examples Included

### 1. Pure Dart Example (`mayr_validator_example.dart`)

A comprehensive pure Dart example showcasing:
- Basic validation
- Global configuration
- Custom rules
- Validation groups
- Chaining validators
- Extension methods

**Run it:**
```bash
dart run example/mayr_validator_example.dart
```

### 2. Flutter Example (`flutter_example/`)

Complete Flutter application examples demonstrating:
- Registration form with multiple fields
- Login form
- Dynamic/conditional validation
- Real-time validation feedback
- Password confirmation
- Custom error messages

**See:** [flutter_example/README.md](flutter_example/README.md) for setup instructions.

## Quick Start

### Basic Validation

```dart
import 'package:mayr_validator/mayr_validator.dart';

void main() {
  // Simple validation
  final error = MayrValidator('test@example.com')
      .required()
      .email()
      .run();
  
  print(error ?? 'Valid!');
}
```

### Global Configuration

```dart
void main() {
  // Setup global messages
  MayrValidationCore().setup({
    'messages': {
      'required': 'This field is required',
      'min': 'Must be at least {min} characters',
      'email': 'Please enter a valid email',
    },
  });
  
  // Use validators
  final error = MayrValidator('')
      .required()
      .run();
  
  print(error); // "This field is required"
}
```

### Custom Rules

```dart
void main() {
  // Register custom rule
  MayrValidationCore().registerRule('userId', (value, params) {
    if (value == null || !value.startsWith('USR_')) {
      return 'Invalid user ID format';
    }
    return null;
  });
  
  // Use custom rule
  final error = MayrValidator('USR_12345')
      .custom('userId')
      .run();
  
  print(error ?? 'Valid!');
}
```

### Validation Groups

```dart
void main() {
  // Register validation group
  MayrValidationCore().registerGroup('username', (validator, params) {
    return validator
        .required()
        .min(3)
        .max(20)
        .alphaDash();
  });
  
  // Use group
  final error = MayrValidator('john_doe')
      .group('username')
      .run();
  
  print(error ?? 'Valid!');
}
```

### Chaining Validators

```dart
void main() {
  // Chain multiple validators
  final error = MayrValidator('test@example.com')
      .required()
      .email()
      .min(5)
      .max(50)
      .lowercase()
      .run();
  
  print(error ?? 'Valid!');
}
```

### Extension Method

```dart
void main() {
  // Use extension method
  final error = 'test@example.com'.mayrValidator()
      .required()
      .email()
      .run();
  
  print(error ?? 'Valid!');
}
```

## Flutter Integration

### In TextFormField

```dart
TextFormField(
  decoration: InputDecoration(labelText: 'Email'),
  validator: (value) => value.mayrValidator()
      .required()
      .email()
      .max(100)
      .run(),
)
```

### With Password Confirmation

```dart
final _passwordController = TextEditingController();

// Password field
TextFormField(
  controller: _passwordController,
  decoration: InputDecoration(labelText: 'Password'),
  obscureText: true,
  validator: (value) => value.mayrValidator()
      .required()
      .min(8)
      .run(),
)

// Confirm password field
TextFormField(
  decoration: InputDecoration(labelText: 'Confirm Password'),
  obscureText: true,
  validator: (value) => value.mayrValidator()
      .required()
      .same(_passwordController.text, 'Passwords must match')
      .run(),
)
```

## Available Validators

MayrValidator includes 50+ built-in validators:

- **Utility**: `required()`, `nullable()`, `requiredIf()`, `requiredUnless()`
- **String**: `email()`, `url()`, `alpha()`, `alphaNum()`, `alphaDash()`, `regex()`, `uuid()`, `json()`, and more
- **Number**: `numeric()`, `integer()`, `decimal()`, `between()`, `gt()`, `lt()`, and more
- **Boolean**: `boolean()`, `accepted()`, `declined()`
- **Array**: `array()`, `contains()`, `distinct()`
- **Date**: `date()`, `after()`, `before()`, `dateEquals()`

See [API.md](../API.md) for complete documentation.

## More Resources

- **API Documentation**: [API.md](../API.md)
- **Design Document**: [DESIGN.md](../DESIGN.md)
- **Main README**: [README.md](../README.md)
- **Changelog**: [CHANGELOG.md](../CHANGELOG.md)
