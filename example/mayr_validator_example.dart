import 'package:mayr_validator/mayr_validator.dart';

void main() {
  print('=== MayrValidator Examples ===\n');

  // Example 1: Basic validation
  print('Example 1: Basic validation');
  basicValidation();
  print('');

  // Example 2: Global configuration
  print('Example 2: Global configuration');
  globalConfiguration();
  print('');

  // Example 3: Custom rules
  print('Example 3: Custom rules');
  customRules();
  print('');

  // Example 4: Validation groups
  print('Example 4: Validation groups');
  validationGroups();
  print('');

  // Example 5: Chaining validators
  print('Example 5: Chaining validators');
  chainingValidators();
  print('');

  // Example 6: Using extension method
  print('Example 6: Using extension method');
  extensionMethod();
  print('');
}

/// Example 1: Basic validation
void basicValidation() {
  // Validate required field
  final error1 = MayrValidator('').required().run();
  print('Empty string required: $error1');

  // Validate email
  final error2 = MayrValidator('test@example.com').email().run();
  print('Valid email: ${error2 ?? "Valid"}');

  final error3 = MayrValidator('invalid-email').email().run();
  print('Invalid email: $error3');

  // Validate min/max length
  final error4 = MayrValidator('ab').min(3).run();
  print('Too short (min 3): $error4');

  final error5 = MayrValidator('abcdef').min(3).max(10).run();
  print('Valid length: ${error5 ?? "Valid"}');
}

/// Example 2: Global configuration
void globalConfiguration() {
  // Setup global configuration
  MayrValidationCore().setup({
    'messages': {
      'required': 'This field cannot be empty',
      'min': 'Minimum length is {min} characters',
      'email': 'Please enter a valid email address',
    },
    'defaults': {
      'min': 3,
      'max': 255,
    },
  });

  final error = MayrValidator('').required().run();
  print('Custom message: $error');

  final error2 = MayrValidator('ab').min(5).run();
  print('Custom min message: $error2');

  // Reset for other examples
  MayrValidationCore().reset();
}

/// Example 3: Custom rules
void customRules() {
  // Register a custom rule
  MayrValidationCore().registerRule('userId', (String? value, Map<String, dynamic>? params) {
    if (value == null || value.isEmpty) return 'User ID is required';
    if (!value.startsWith('USR_')) return 'User ID must start with USR_';
    if (!RegExp(r'^USR_[A-Z0-9]+$').hasMatch(value)) {
      return 'Invalid user ID format';
    }
    return null;
  });

  // Use the custom rule
  final error1 = MayrValidator('USR_12345').custom('userId').run();
  print('Valid user ID: ${error1 ?? "Valid"}');

  final error2 = MayrValidator('INVALID').custom('userId').run();
  print('Invalid user ID: $error2');

  // Reset for other examples
  MayrValidationCore().reset();
}

/// Example 4: Validation groups
void validationGroups() {
  // Register a validation group for username
  MayrValidationCore().registerGroup('username', (validator, params) {
    return validator.required().min(3).max(20).alphaDash();
  });

  // Register a validation group for password
  MayrValidationCore().registerGroup('strongPassword', (validator, params) {
    return validator
        .required()
        .min(8)
        .regex(r'(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])');
  });

  // Use validation groups
  final error1 = MayrValidator('john_doe').group('username').run();
  print('Valid username: ${error1 ?? "Valid"}');

  final error2 = MayrValidator('ab').group('username').run();
  print('Invalid username (too short): $error2');

  final error3 = MayrValidator('Password123').group('strongPassword').run();
  print('Valid strong password: ${error3 ?? "Valid"}');

  final error4 = MayrValidator('weak').group('strongPassword').run();
  print('Invalid password: $error4');

  // Reset for other examples
  MayrValidationCore().reset();
}

/// Example 5: Chaining validators
void chainingValidators() {
  // Chain multiple validators
  final error1 = MayrValidator('test@example.com')
      .required()
      .email()
      .min(5)
      .max(50)
      .run();
  print('Valid email with length: ${error1 ?? "Valid"}');

  final error2 = MayrValidator('john123')
      .required()
      .alphaNum()
      .min(3)
      .max(20)
      .run();
  print('Valid username: ${error2 ?? "Valid"}');

  // Number validation
  final error3 = MayrValidator(25)
      .required()
      .numeric()
      .between(18, 100)
      .run();
  print('Valid age: ${error3 ?? "Valid"}');

  // Array validation
  final error4 = MayrValidator(['apple', 'banana', 'cherry'])
      .required()
      .array()
      .min(2)
      .distinct()
      .run();
  print('Valid array: ${error4 ?? "Valid"}');
}

/// Example 6: Using extension method
void extensionMethod() {
  // Use the mayrValidator() extension on String
  final error1 = 'test@example.com'.mayrValidator()
      .required()
      .email()
      .run();
  print('Valid email: ${error1 ?? "Valid"}');

  final error2 = 'ab'.mayrValidator()
      .required()
      .min(3)
      .run();
  print('Too short: $error2');

  // Works with null strings
  String? nullString;
  final error3 = nullString.mayrValidator().required().run();
  print('Null string: $error3');
}

/// Example for Flutter usage (commented out as it requires Flutter SDK)
/// 
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:mayr_validator/mayr_validator.dart';
/// 
/// class MyForm extends StatefulWidget {
///   @override
///   _MyFormState createState() => _MyFormState();
/// }
/// 
/// class _MyFormState extends State<MyForm> {
///   final _formKey = GlobalKey<FormState>();
/// 
///   @override
///   void initState() {
///     super.initState();
///     
///     // Setup global validation messages
///     MayrValidationCore().setup({
///       'messages': {
///         'required': 'This field is required',
///         'min': 'Must be at least {min} characters',
///         'email': 'Please enter a valid email address',
///       },
///     });
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Form(
///       key: _formKey,
///       child: Column(
///         children: [
///           // Email field
///           TextFormField(
///             decoration: InputDecoration(labelText: 'Email'),
///             validator: (value) => value.mayrValidator()
///                 .required()
///                 .email()
///                 .run(),
///           ),
///           
///           // Username field
///           TextFormField(
///             decoration: InputDecoration(labelText: 'Username'),
///             validator: (value) => value.mayrValidator()
///                 .required()
///                 .min(3)
///                 .max(20)
///                 .alphaDash()
///                 .run(),
///           ),
///           
///           // Password field
///           TextFormField(
///             decoration: InputDecoration(labelText: 'Password'),
///             obscureText: true,
///             validator: (value) => value.mayrValidator()
///                 .required()
///                 .min(8)
///                 .regex(r'(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])')
///                 .run(),
///           ),
///           
///           // Submit button
///           ElevatedButton(
///             onPressed: () {
///               if (_formKey.currentState!.validate()) {
///                 // Form is valid, process data
///                 print('Form is valid!');
///               }
///             },
///             child: Text('Submit'),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
