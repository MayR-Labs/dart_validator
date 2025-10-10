import '../validators/mayr_validator.dart';

/// Extension on String to enable the fluent `mayrValidator()` syntax.
///
/// Example:
/// ```dart
/// final error = 'test@example.com'.mayrValidator()
///     .required()
///     .email()
///     .run();
/// ```
extension MayrValidatorExtension on String? {
  /// Creates a MayrValidator instance for this string value.
  MayrValidator mayrValidator() {
    return MayrValidator(this);
  }
}
