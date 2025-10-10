import 'package:mayr_validator/mayr_validator.dart';

/// Setup global validation configuration and register custom rules/groups.
///
/// This function should be called once at the start of your Flutter application,
/// typically in the main() function before calling runApp().
void setupValidations() {
  // Setup global validation configuration
  MayrValidationCore().setup({
    'messages': {
      'required': 'This field is required',
      'min': 'Must be at least {min} characters',
      'max': 'Must not exceed {max} characters',
      'email': 'Please enter a valid email address',
      'numeric': 'Must be a number',
      'between': 'Must be between {min} and {max}',
    },
    'defaults': {'min': 3, 'max': 255},
  });

  // Register custom validation groups
  MayrValidationCore().registerGroup('username', (validator, params) {
    return validator.required().min(3).max(20).alphaDash();
  });

  MayrValidationCore().registerGroup('strongPassword', (validator, params) {
    return validator
        .required()
        .min(8)
        .regex(r'(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])')
        .notRegex(r'\s');
  });
}
