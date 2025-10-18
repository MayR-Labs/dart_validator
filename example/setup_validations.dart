import 'package:mayr_validator/mayr_validator.dart';

/// Setup global validation configuration and register custom rules/groups.
///
/// This function should be called once at the start of your application,
/// typically in the main() function before running any validation logic.
void setupValidations() {
  // Setup global configuration
  MayrValidationCore().setup({
    'messages': {
      'required': 'This field cannot be empty',
      'min': 'Minimum length is {min} characters',
      'max': 'Must not exceed {max} characters',
      'email': 'Please enter a valid email address',
    },
    'defaults': {'min': 3, 'max': 255},
  });

  // Register custom validation rule for user IDs
  MayrValidationCore().registerRule('userId', (
    String? value,
    Map<String, dynamic>? params,
  ) {
    if (value == null || value.isEmpty) return 'User ID is required';
    if (!value.startsWith('USR_')) return 'User ID must start with USR_';
    if (!RegExp(r'^USR_[A-Z0-9]+$').hasMatch(value)) {
      return 'Invalid user ID format';
    }
    return null;
  });

  // Register validation group for username
  MayrValidationCore().registerGroup('username', (validator, params) {
    return validator.required().min(3).max(20).alphaDash();
  });

  // Register validation group for strong passwords
  MayrValidationCore().registerGroup('strongPassword', (validator, params) {
    return validator
        .required()
        .min(8)
        .regex(r'(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])');
  });
}
