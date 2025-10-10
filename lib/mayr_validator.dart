/// MayrValidations - A powerful yet elegant validation library for Dart and Flutter.
///
/// Inspired by Laravel's validator syntax and philosophy, MayrValidations provides
/// a fluent API to build validations that are expressive, chainable, and extensible.
///
/// Example:
/// ```dart
/// import 'package:mayr_validator/mayr_validator.dart';
///
/// // Basic usage
/// final error = MayrValidator('test@example.com')
///     .required()
///     .email()
///     .run();
///
/// // With extension method
/// final error2 = 'username'.mayrValidator()
///     .required()
///     .min(3)
///     .max(20)
///     .run();
/// ```
library;

export 'src/core/mayr_validation_core.dart';
export 'src/validators/mayr_validator.dart';
export 'src/extensions/mayr_validator_extension.dart';
