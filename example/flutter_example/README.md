# Flutter Example for MayrValidator

This directory contains a complete Flutter example demonstrating how to use MayrValidator in a Flutter application.

## Features Demonstrated

- **Registration Form**: Complete form with email, username, password, and age validation
- **Login Form**: Simple login with email and password
- **Dynamic Validation**: Conditional validation based on user selection

## How to Run

Since this is a Flutter-specific example, you'll need to:

1. **Create a new Flutter project:**
   ```bash
   flutter create my_validator_app
   cd my_validator_app
   ```

2. **Add MayrValidator to pubspec.yaml:**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     dart_validator: ^1.0.0
   ```

3. **Copy the example:**
   ```bash
   # Copy the main.dart file to your Flutter project
   cp example/flutter_example/main.dart lib/main.dart
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Example Usage in Flutter

### Basic TextFormField Validation

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

### Password Confirmation

```dart
TextFormField(
  controller: _passwordController,
  decoration: InputDecoration(labelText: 'Password'),
  obscureText: true,
  validator: (value) => value.mayrValidator()
      .required()
      .min(8)
      .run(),
),

TextFormField(
  decoration: InputDecoration(labelText: 'Confirm Password'),
  obscureText: true,
  validator: (value) => value.mayrValidator()
      .required()
      .same(_passwordController.text, 'Passwords must match')
      .run(),
)
```

### Using Validation Groups

```dart
// Setup in initState
MayrValidationCore().registerGroup('username', (validator, params) {
  return validator
      .required()
      .min(3)
      .max(20)
      .alphaDash();
});

// Use in TextFormField
TextFormField(
  decoration: InputDecoration(labelText: 'Username'),
  validator: (value) => value.mayrValidator()
      .group('username')
      .run(),
)
```

## Screenshots

The example includes:
- ✅ Real-time validation feedback
- ✅ Custom error messages
- ✅ Multiple validation rules
- ✅ Password matching
- ✅ Conditional validation
- ✅ Form submission handling

## Note

This example is excluded from the main package's analysis because it requires Flutter dependencies. When you add it to a Flutter project, all dependencies will be available and the example will work perfectly.
