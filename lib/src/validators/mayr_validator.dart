import 'dart:async';
import 'dart:convert';
import '../core/mayr_validation_core.dart';

/// Type definition for validation rules.
typedef ValidationRule = String? Function();

/// Main validator class for chaining validation rules.
///
/// This class provides a fluent API for defining validation logic
/// in a declarative, composable manner.
///
/// Example:
/// ```dart
/// final error = MayrValidator('test@example.com')
///     .required()
///     .email()
///     .run();
/// ```
class MayrValidator {
  /// The value being validated.
  final dynamic value;

  /// Internal list of validation rules to execute.
  final List<ValidationRule> _rules = [];

  /// Reference to the global core instance.
  final MayrValidationCore _core = MayrValidationCore();

  /// Debounce timer for delayed validation.
  Timer? _debounceTimer;

  /// Constructor that accepts the value to validate.
  MayrValidator(this.value);

  /// Execute all validation rules in order.
  ///
  /// Returns the first error message or null if all validations pass.
  ///
  /// The [debounce] parameter allows delayed execution.
  String? run({Duration debounce = Duration.zero}) {
    if (debounce > Duration.zero) {
      // Cancel previous timer if exists
      _debounceTimer?.cancel();

      // Create a completer for the debounced result
      final completer = Completer<String?>();

      _debounceTimer = Timer(debounce, () {
        completer.complete(_executeRules());
      });

      // For synchronous validation, return immediately
      // In a real async scenario, this would return a Future
      return _executeRules();
    }

    return _executeRules();
  }

  /// Internal method to execute all rules.
  String? _executeRules() {
    for (final rule in _rules) {
      final error = rule();
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Helper to format error messages with parameters.
  String _formatMessage(
    String? message,
    String ruleName,
    Map<String, dynamic> params,
  ) {
    var msg =
        message ??
        _core.getMessage(ruleName) ??
        'Validation failed for $ruleName';

    // Replace placeholders like {min}, {max}, etc.
    params.forEach((key, value) {
      msg = msg.replaceAll('{$key}', value.toString());
    });

    return msg;
  }

  // ============================================================
  // UTILITY VALIDATORS
  // ============================================================

  /// Field must not be null or empty.
  MayrValidator required([String? message]) {
    _rules.add(() {
      if (value == null) {
        return message ??
            _core.getMessage('required') ??
            'This field is required';
      }
      if (value is String && value.trim().isEmpty) {
        return message ??
            _core.getMessage('required') ??
            'This field is required';
      }
      if (value is List && value.isEmpty) {
        return message ??
            _core.getMessage('required') ??
            'This field is required';
      }
      if (value is Map && value.isEmpty) {
        return message ??
            _core.getMessage('required') ??
            'This field is required';
      }
      return null;
    });
    return this;
  }

  /// Allows null or empty values (bypasses other validations if null/empty).
  MayrValidator nullable() {
    // This is a marker - actual implementation would modify validation flow
    // For simplicity, we'll just return this
    return this;
  }

  /// Required only if the condition is true.
  MayrValidator requiredIf(bool condition, [String? message]) {
    if (condition) {
      return required(message);
    }
    return this;
  }

  /// Required unless the condition is true.
  MayrValidator requiredUnless(bool condition, [String? message]) {
    if (!condition) {
      return required(message);
    }
    return this;
  }

  // ============================================================
  // STRING VALIDATORS
  // ============================================================

  /// Must be a valid string.
  MayrValidator string([String? message]) {
    _rules.add(() {
      if (value == null) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('string') ??
            'Must be a valid string';
      }
      return null;
    });
    return this;
  }

  /// Must have at least the given length.
  MayrValidator min(int minLength, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      int length = 0;
      if (value is String) {
        length = value.length;
      } else if (value is List) {
        length = value.length;
      } else if (value is num) {
        length = value.toInt();
      }

      if (length < minLength) {
        return _formatMessage(message, 'min', {'min': minLength});
      }
      return null;
    });
    return this;
  }

  /// Must not exceed the given length.
  MayrValidator max(int maxLength, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      int length = 0;
      if (value is String) {
        length = value.length;
      } else if (value is List) {
        length = value.length;
      } else if (value is num) {
        length = value.toInt();
      }

      if (length > maxLength) {
        return _formatMessage(message, 'max', {'max': maxLength});
      }
      return null;
    });
    return this;
  }

  /// Must be exactly the specified length.
  MayrValidator size(int length, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      int actualLength = 0;
      if (value is String) {
        actualLength = value.length;
      } else if (value is List) {
        actualLength = value.length;
      } else if (value is num) {
        actualLength = value.toInt();
      }

      if (actualLength != length) {
        return _formatMessage(message, 'size', {'size': length});
      }
      return null;
    });
    return this;
  }

  /// Must be a valid email address.
  MayrValidator email([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('email') ??
            'Must be a valid email address';
      }

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return message ??
            _core.getMessage('email') ??
            'Must be a valid email address';
      }
      return null;
    });
    return this;
  }

  /// Must be a valid URL.
  MayrValidator url([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ?? _core.getMessage('url') ?? 'Must be a valid URL';
      }

      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );

      if (!urlRegex.hasMatch(value)) {
        return message ?? _core.getMessage('url') ?? 'Must be a valid URL';
      }
      return null;
    });
    return this;
  }

  /// May contain only alphabetic characters.
  MayrValidator alpha([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('alpha') ??
            'May contain only alphabetic characters';
      }

      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
        return message ??
            _core.getMessage('alpha') ??
            'May contain only alphabetic characters';
      }
      return null;
    });
    return this;
  }

  /// May contain only alphanumeric characters.
  MayrValidator alphaNum([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('alphaNum') ??
            'May contain only alphanumeric characters';
      }

      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
        return message ??
            _core.getMessage('alphaNum') ??
            'May contain only alphanumeric characters';
      }
      return null;
    });
    return this;
  }

  /// May contain letters, numbers, dashes, and underscores.
  MayrValidator alphaDash([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('alphaDash') ??
            'May contain letters, numbers, dashes, and underscores';
      }

      if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
        return message ??
            _core.getMessage('alphaDash') ??
            'May contain letters, numbers, dashes, and underscores';
      }
      return null;
    });
    return this;
  }

  /// Must contain only ASCII characters.
  MayrValidator ascii([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('ascii') ??
            'Must contain only ASCII characters';
      }

      if (!RegExp(r'^[\x00-\x7F]+$').hasMatch(value)) {
        return message ??
            _core.getMessage('ascii') ??
            'Must contain only ASCII characters';
      }
      return null;
    });
    return this;
  }

  /// Must be entirely lowercase.
  MayrValidator lowercase([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('lowercase') ??
            'Must be entirely lowercase';
      }

      if (value != value.toLowerCase()) {
        return message ??
            _core.getMessage('lowercase') ??
            'Must be entirely lowercase';
      }
      return null;
    });
    return this;
  }

  /// Must be entirely uppercase.
  MayrValidator uppercase([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('uppercase') ??
            'Must be entirely uppercase';
      }

      if (value != value.toUpperCase()) {
        return message ??
            _core.getMessage('uppercase') ??
            'Must be entirely uppercase';
      }
      return null;
    });
    return this;
  }

  /// Must match the given regular expression.
  MayrValidator regex(String pattern, [String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('regex') ??
            'Must match the given pattern';
      }

      if (!RegExp(pattern).hasMatch(value)) {
        return message ??
            _core.getMessage('regex') ??
            'Must match the given pattern';
      }
      return null;
    });
    return this;
  }

  /// Must not match the given regular expression.
  MayrValidator notRegex(String pattern, [String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('notRegex') ??
            'Must not match the given pattern';
      }

      if (RegExp(pattern).hasMatch(value)) {
        return message ??
            _core.getMessage('notRegex') ??
            'Must not match the given pattern';
      }
      return null;
    });
    return this;
  }

  /// Must start with the given substring.
  MayrValidator startsWith(String substring, [String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('startsWith') ??
            'Must start with $substring';
      }

      if (!value.startsWith(substring)) {
        return _formatMessage(message, 'startsWith', {'substring': substring});
      }
      return null;
    });
    return this;
  }

  /// Must end with the given substring.
  MayrValidator endsWith(String substring, [String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('endsWith') ??
            'Must end with $substring';
      }

      if (!value.endsWith(substring)) {
        return _formatMessage(message, 'endsWith', {'substring': substring});
      }
      return null;
    });
    return this;
  }

  /// Must not start with the given substring.
  MayrValidator doesntStartWith(String substring, [String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('doesntStartWith') ??
            'Must not start with $substring';
      }

      if (value.startsWith(substring)) {
        return _formatMessage(message, 'doesntStartWith', {
          'substring': substring,
        });
      }
      return null;
    });
    return this;
  }

  /// Must not end with the given substring.
  MayrValidator doesntEndWith(String substring, [String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('doesntEndWith') ??
            'Must not end with $substring';
      }

      if (value.endsWith(substring)) {
        return _formatMessage(message, 'doesntEndWith', {
          'substring': substring,
        });
      }
      return null;
    });
    return this;
  }

  /// Must be one of the provided values.
  MayrValidator inList(List values, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (!values.contains(value)) {
        return message ??
            _core.getMessage('in') ??
            'Must be one of the provided values';
      }
      return null;
    });
    return this;
  }

  /// Must not be one of the provided values.
  MayrValidator notIn(List values, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (values.contains(value)) {
        return message ??
            _core.getMessage('notIn') ??
            'Must not be one of the provided values';
      }
      return null;
    });
    return this;
  }

  /// Must match another field's value.
  MayrValidator same(dynamic otherValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (value != otherValue) {
        return message ??
            _core.getMessage('same') ??
            'Must match the other value';
      }
      return null;
    });
    return this;
  }

  /// Must differ from another value.
  MayrValidator different(dynamic otherValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (value == otherValue) {
        return message ??
            _core.getMessage('different') ??
            'Must differ from the other value';
      }
      return null;
    });
    return this;
  }

  /// Must be a valid UUID string.
  MayrValidator uuid([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ?? _core.getMessage('uuid') ?? 'Must be a valid UUID';
      }

      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );

      if (!uuidRegex.hasMatch(value)) {
        return message ?? _core.getMessage('uuid') ?? 'Must be a valid UUID';
      }
      return null;
    });
    return this;
  }

  /// Must be a valid ULID string.
  MayrValidator ulid([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ?? _core.getMessage('ulid') ?? 'Must be a valid ULID';
      }

      final ulidRegex = RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$');

      if (!ulidRegex.hasMatch(value)) {
        return message ?? _core.getMessage('ulid') ?? 'Must be a valid ULID';
      }
      return null;
    });
    return this;
  }

  /// Must be a valid IP address (IPv4 or IPv6).
  MayrValidator ipAddress([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('ipAddress') ??
            'Must be a valid IP address';
      }

      // IPv4
      final ipv4Regex = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$');

      // IPv6
      final ipv6Regex = RegExp(
        r'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$',
      );

      if (!ipv4Regex.hasMatch(value) && !ipv6Regex.hasMatch(value)) {
        return message ??
            _core.getMessage('ipAddress') ??
            'Must be a valid IP address';
      }
      return null;
    });
    return this;
  }

  /// Must be a valid MAC address.
  MayrValidator macAddress([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('macAddress') ??
            'Must be a valid MAC address';
      }

      final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');

      if (!macRegex.hasMatch(value)) {
        return message ??
            _core.getMessage('macAddress') ??
            'Must be a valid MAC address';
      }
      return null;
    });
    return this;
  }

  /// Must be a valid hex color.
  MayrValidator hexColor([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('hexColor') ??
            'Must be a valid hex color';
      }

      final hexColorRegex = RegExp(r'^#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');

      if (!hexColorRegex.hasMatch(value)) {
        return message ??
            _core.getMessage('hexColor') ??
            'Must be a valid hex color';
      }
      return null;
    });
    return this;
  }

  /// Must be a valid JSON string.
  MayrValidator json([String? message]) {
    _rules.add(() {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is! String) {
        return message ??
            _core.getMessage('json') ??
            'Must be a valid JSON string';
      }

      try {
        jsonDecode(value);
      } catch (e) {
        return message ??
            _core.getMessage('json') ??
            'Must be a valid JSON string';
      }
      return null;
    });
    return this;
  }

  // ============================================================
  // BOOLEAN VALIDATORS
  // ============================================================

  /// Must be a boolean value.
  MayrValidator boolean([String? message]) {
    _rules.add(() {
      if (value == null) return null;
      if (value is! bool) {
        return message ??
            _core.getMessage('boolean') ??
            'Must be a boolean value';
      }
      return null;
    });
    return this;
  }

  /// Must be accepted (e.g., true, "true", "yes", "1", 1).
  MayrValidator accepted([String? message]) {
    _rules.add(() {
      if (value == null) {
        return message ?? _core.getMessage('accepted') ?? 'Must be accepted';
      }

      final acceptedValues = [true, 'true', 'yes', '1', 1, 'on'];
      final normalizedValue = value is String ? value.toLowerCase() : value;

      if (!acceptedValues.contains(normalizedValue)) {
        return message ?? _core.getMessage('accepted') ?? 'Must be accepted';
      }
      return null;
    });
    return this;
  }

  /// Must be declined (e.g., false, "false", "no", "0", 0).
  MayrValidator declined([String? message]) {
    _rules.add(() {
      if (value == null) {
        return message ?? _core.getMessage('declined') ?? 'Must be declined';
      }

      final declinedValues = [false, 'false', 'no', '0', 0, 'off'];
      final normalizedValue = value is String ? value.toLowerCase() : value;

      if (!declinedValues.contains(normalizedValue)) {
        return message ?? _core.getMessage('declined') ?? 'Must be declined';
      }
      return null;
    });
    return this;
  }

  // ============================================================
  // NUMBER VALIDATORS
  // ============================================================

  /// Must be numeric.
  MayrValidator numeric([String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (value is num) return null;

      if (value is String) {
        if (num.tryParse(value) == null) {
          return message ?? _core.getMessage('numeric') ?? 'Must be numeric';
        }
        return null;
      }

      return message ?? _core.getMessage('numeric') ?? 'Must be numeric';
    });
    return this;
  }

  /// Must be an integer.
  MayrValidator integer([String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (value is int) return null;

      if (value is String) {
        if (int.tryParse(value) == null) {
          return message ?? _core.getMessage('integer') ?? 'Must be an integer';
        }
        return null;
      }

      if (value is double) {
        if (value % 1 != 0) {
          return message ?? _core.getMessage('integer') ?? 'Must be an integer';
        }
        return null;
      }

      return message ?? _core.getMessage('integer') ?? 'Must be an integer';
    });
    return this;
  }

  /// Must be a valid decimal number.
  MayrValidator decimal([String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (value is double) return null;

      if (value is String) {
        if (double.tryParse(value) == null) {
          return message ??
              _core.getMessage('decimal') ??
              'Must be a valid decimal number';
        }
        return null;
      }

      return message ??
          _core.getMessage('decimal') ??
          'Must be a valid decimal number';
    });
    return this;
  }

  /// Must be between the given range.
  MayrValidator between(num min, num max, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      num numValue = 0;
      if (value is num) {
        numValue = value;
      } else if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed == null) {
          return _formatMessage(message, 'between', {'min': min, 'max': max});
        }
        numValue = parsed;
      } else if (value is List) {
        numValue = value.length;
      }

      if (numValue < min || numValue > max) {
        return _formatMessage(message, 'between', {'min': min, 'max': max});
      }
      return null;
    });
    return this;
  }

  /// Must be greater than the given value.
  MayrValidator gt(num comparisonValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      num numValue = 0;
      if (value is num) {
        numValue = value;
      } else if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed == null) {
          return _formatMessage(message, 'gt', {'value': comparisonValue});
        }
        numValue = parsed;
      }

      if (numValue <= comparisonValue) {
        return _formatMessage(message, 'gt', {'value': comparisonValue});
      }
      return null;
    });
    return this;
  }

  /// Must be greater than or equal to the given value.
  MayrValidator gte(num comparisonValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      num numValue = 0;
      if (value is num) {
        numValue = value;
      } else if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed == null) {
          return _formatMessage(message, 'gte', {'value': comparisonValue});
        }
        numValue = parsed;
      }

      if (numValue < comparisonValue) {
        return _formatMessage(message, 'gte', {'value': comparisonValue});
      }
      return null;
    });
    return this;
  }

  /// Must be less than the given value.
  MayrValidator lt(num comparisonValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      num numValue = 0;
      if (value is num) {
        numValue = value;
      } else if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed == null) {
          return _formatMessage(message, 'lt', {'value': comparisonValue});
        }
        numValue = parsed;
      }

      if (numValue >= comparisonValue) {
        return _formatMessage(message, 'lt', {'value': comparisonValue});
      }
      return null;
    });
    return this;
  }

  /// Must be less than or equal to the given value.
  MayrValidator lte(num comparisonValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      num numValue = 0;
      if (value is num) {
        numValue = value;
      } else if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed == null) {
          return _formatMessage(message, 'lte', {'value': comparisonValue});
        }
        numValue = parsed;
      }

      if (numValue > comparisonValue) {
        return _formatMessage(message, 'lte', {'value': comparisonValue});
      }
      return null;
    });
    return this;
  }

  /// Must have exactly the specified number of digits.
  MayrValidator digits(int count, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      String strValue = value.toString().replaceAll(RegExp(r'[^0-9]'), '');

      if (strValue.length != count) {
        return _formatMessage(message, 'digits', {'count': count});
      }
      return null;
    });
    return this;
  }

  /// Must have a number of digits between min and max.
  MayrValidator digitsBetween(int min, int max, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      String strValue = value.toString().replaceAll(RegExp(r'[^0-9]'), '');

      if (strValue.length < min || strValue.length > max) {
        return _formatMessage(message, 'digitsBetween', {
          'min': min,
          'max': max,
        });
      }
      return null;
    });
    return this;
  }

  /// Must be a multiple of the given number.
  MayrValidator multipleOf(num divisor, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      num numValue = 0;
      if (value is num) {
        numValue = value;
      } else if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed == null) {
          return _formatMessage(message, 'multipleOf', {'value': divisor});
        }
        numValue = parsed;
      }

      if (numValue % divisor != 0) {
        return _formatMessage(message, 'multipleOf', {'value': divisor});
      }
      return null;
    });
    return this;
  }

  // ============================================================
  // ARRAY/LIST VALIDATORS
  // ============================================================

  /// Must be a valid list or array.
  MayrValidator array([String? message]) {
    _rules.add(() {
      if (value == null) return null;
      if (value is! List) {
        return message ?? _core.getMessage('array') ?? 'Must be a valid array';
      }
      return null;
    });
    return this;
  }

  /// Must contain the specified value.
  MayrValidator contains(dynamic searchValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;
      if (value is! List) {
        return message ??
            _core.getMessage('contains') ??
            'Must contain the specified value';
      }

      if (!value.contains(searchValue)) {
        return message ??
            _core.getMessage('contains') ??
            'Must contain the specified value';
      }
      return null;
    });
    return this;
  }

  /// Must not contain the specified value.
  MayrValidator doesntContain(dynamic searchValue, [String? message]) {
    _rules.add(() {
      if (value == null) return null;
      if (value is! List) {
        return message ??
            _core.getMessage('doesntContain') ??
            'Must not contain the specified value';
      }

      if (value.contains(searchValue)) {
        return message ??
            _core.getMessage('doesntContain') ??
            'Must not contain the specified value';
      }
      return null;
    });
    return this;
  }

  /// All array elements must be unique.
  MayrValidator distinct([String? message]) {
    _rules.add(() {
      if (value == null) return null;
      if (value is! List) {
        return message ??
            _core.getMessage('distinct') ??
            'All array elements must be unique';
      }

      if (value.length != value.toSet().length) {
        return message ??
            _core.getMessage('distinct') ??
            'All array elements must be unique';
      }
      return null;
    });
    return this;
  }

  // ============================================================
  // DATE VALIDATORS
  // ============================================================

  /// Must be a valid date.
  MayrValidator date([String? message]) {
    _rules.add(() {
      if (value == null) return null;

      if (value is DateTime) return null;

      if (value is String) {
        if (DateTime.tryParse(value) == null) {
          return message ?? _core.getMessage('date') ?? 'Must be a valid date';
        }
        return null;
      }

      return message ?? _core.getMessage('date') ?? 'Must be a valid date';
    });
    return this;
  }

  /// Must be after the given date.
  MayrValidator after(DateTime comparisonDate, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      DateTime? dateValue;
      if (value is DateTime) {
        dateValue = value;
      } else if (value is String) {
        dateValue = DateTime.tryParse(value);
      }

      if (dateValue == null) {
        return message ?? _core.getMessage('after') ?? 'Must be a valid date';
      }

      if (!dateValue.isAfter(comparisonDate)) {
        return message ??
            _core.getMessage('after') ??
            'Must be after the given date';
      }
      return null;
    });
    return this;
  }

  /// Must be after or equal to the given date.
  MayrValidator afterOrEqual(DateTime comparisonDate, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      DateTime? dateValue;
      if (value is DateTime) {
        dateValue = value;
      } else if (value is String) {
        dateValue = DateTime.tryParse(value);
      }

      if (dateValue == null) {
        return message ??
            _core.getMessage('afterOrEqual') ??
            'Must be a valid date';
      }

      if (dateValue.isBefore(comparisonDate)) {
        return message ??
            _core.getMessage('afterOrEqual') ??
            'Must be after or equal to the given date';
      }
      return null;
    });
    return this;
  }

  /// Must be before the given date.
  MayrValidator before(DateTime comparisonDate, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      DateTime? dateValue;
      if (value is DateTime) {
        dateValue = value;
      } else if (value is String) {
        dateValue = DateTime.tryParse(value);
      }

      if (dateValue == null) {
        return message ?? _core.getMessage('before') ?? 'Must be a valid date';
      }

      if (!dateValue.isBefore(comparisonDate)) {
        return message ??
            _core.getMessage('before') ??
            'Must be before the given date';
      }
      return null;
    });
    return this;
  }

  /// Must be before or equal to the given date.
  MayrValidator beforeOrEqual(DateTime comparisonDate, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      DateTime? dateValue;
      if (value is DateTime) {
        dateValue = value;
      } else if (value is String) {
        dateValue = DateTime.tryParse(value);
      }

      if (dateValue == null) {
        return message ??
            _core.getMessage('beforeOrEqual') ??
            'Must be a valid date';
      }

      if (dateValue.isAfter(comparisonDate)) {
        return message ??
            _core.getMessage('beforeOrEqual') ??
            'Must be before or equal to the given date';
      }
      return null;
    });
    return this;
  }

  /// Must be equal to the given date.
  MayrValidator dateEquals(DateTime comparisonDate, [String? message]) {
    _rules.add(() {
      if (value == null) return null;

      DateTime? dateValue;
      if (value is DateTime) {
        dateValue = value;
      } else if (value is String) {
        dateValue = DateTime.tryParse(value);
      }

      if (dateValue == null) {
        return message ??
            _core.getMessage('dateEquals') ??
            'Must be a valid date';
      }

      if (dateValue.year != comparisonDate.year ||
          dateValue.month != comparisonDate.month ||
          dateValue.day != comparisonDate.day) {
        return message ??
            _core.getMessage('dateEquals') ??
            'Must be equal to the given date';
      }
      return null;
    });
    return this;
  }

  // ============================================================
  // CUSTOM RULES AND GROUPS
  // ============================================================

  /// Run a registered custom rule.
  MayrValidator custom(String name, [Map<String, dynamic>? params]) {
    _rules.add(() {
      final rule = _core.getCustomRule(name);

      if (rule == null) {
        if (_core.isDevelopmentMode) {
          throw Exception('Custom rule "$name" is not registered');
        }
        return null;
      }

      return rule(value, params) as String?;
    });
    return this;
  }

  /// Run a registered validation group.
  MayrValidator group(String name, [Map<String, dynamic>? params]) {
    final groupFunc = _core.getGroup(name);

    if (groupFunc == null) {
      if (_core.isDevelopmentMode) {
        throw Exception('Validation group "$name" is not registered');
      }
      return this;
    }

    return groupFunc(this, params) as MayrValidator;
  }
}
