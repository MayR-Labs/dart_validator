/// Core singleton class for managing global validation configuration.
///
/// This class holds global configuration (`messages`, `defaults`),
/// registers custom validation rules and groups, and handles
/// environment-aware behavior.
class MayrValidationCore {
  static final MayrValidationCore _instance = MayrValidationCore._internal();

  /// Factory constructor that returns the singleton instance.
  factory MayrValidationCore() => _instance;

  MayrValidationCore._internal();

  /// Stores custom validation rules.
  final Map<String, Function> _customRules = {};

  /// Stores validation groups.
  final Map<String, Function> _groups = {};

  /// Stores global configuration (messages, defaults).
  final Map<String, dynamic> _config = {};

  /// Global configuration getter.
  Map<String, dynamic> get config => Map.unmodifiable(_config);

  /// Setup global configuration.
  ///
  /// Merges the provided configuration with existing configuration.
  ///
  /// Example:
  /// ```dart
  /// MayrValidationCore().setup({
  ///   'messages': {
  ///     'required': 'This field is required',
  ///     'min': 'Must be at least {min} characters',
  ///   },
  ///   'defaults': {
  ///     'min': 3,
  ///     'max': 255,
  ///   },
  /// });
  /// ```
  void setup(Map<String, dynamic> config) {
    config.forEach((key, value) {
      if (value is Map && _config[key] is Map) {
        _config[key] = {..._config[key] as Map, ...value};
      } else {
        _config[key] = value;
      }
    });
  }

  /// Register a custom validation rule.
  ///
  /// Example:
  /// ```dart
  /// MayrValidationCore().registerRule('userId', (String? value, Map<String, dynamic>? params) {
  ///   if (value == null || value.isEmpty) return 'User ID is required';
  ///   if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) return 'Invalid user ID';
  ///   return null;
  /// });
  /// ```
  void registerRule(String name, Function rule) {
    _customRules[name] = rule;
  }

  /// Register a validation group.
  ///
  /// Example:
  /// ```dart
  /// MayrValidationCore().registerGroup('username', (validator, params) {
  ///   return validator.required().min(3).max(20);
  /// });
  /// ```
  void registerGroup(String name, Function group) {
    _groups[name] = group;
  }

  /// Get a custom rule by name.
  Function? getCustomRule(String name) {
    return _customRules[name];
  }

  /// Get a validation group by name.
  Function? getGroup(String name) {
    return _groups[name];
  }

  /// Get a message template from configuration.
  String? getMessage(String ruleName) {
    final messages = _config['messages'] as Map?;
    return messages?[ruleName] as String?;
  }

  /// Get a default value from configuration.
  dynamic getDefault(String key) {
    final defaults = _config['defaults'] as Map?;
    return defaults?[key];
  }

  /// Check if running in development mode.
  bool get isDevelopmentMode {
    // Check if asserts are enabled (true in debug mode)
    var inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Reset the entire configuration (useful for testing).
  void reset() {
    _customRules.clear();
    _groups.clear();
    _config.clear();
  }
}
