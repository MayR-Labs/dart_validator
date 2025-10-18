# GitHub Copilot Instructions for dart_validator

## Project Overview
This is a Flutter/Dart validation package called **mayr_validator**, providing a fluent API for building validations inspired by Laravel's validator syntax.

## Package Information
- **Organization**: MayR Labs (https://github.com/MayR-Labs)
- **Website**: https://mayrlabs.com
- **Repository**: https://github.com/MayR-Labs/dart_validator
- **Package Name**: mayr_validator
- **License**: MIT License, Copyright (c) 2025 MayR Labs

## Development Guidelines

### Code Style
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format all Dart code
- Run `dart analyze` or `flutter analyze` to check for issues before committing
- Maintain consistency with existing code patterns

### Architecture
- **Core Singleton Pattern**: `MayrValidationCore` handles global configuration
- **Fluent API**: `MayrValidator` provides chainable validation methods
- **Extension Methods**: Enable elegant syntax like `value.mayrValidator()`
- **Separation of Concerns**: Keep validators, core logic, and extensions separate

### Testing
- Write comprehensive tests for all validation rules
- Use descriptive test names that explain what is being tested
- Follow the existing test structure with `group()` and `test()` blocks
- Aim for high test coverage
- Run tests with `flutter test` or `dart test`

### Adding New Validators
When adding a new validation rule:

1. **Add the method to `MayrValidator` class** in `lib/src/validators/`
2. **Include dartdoc comments** explaining the validator's purpose and parameters
3. **Add comprehensive tests** covering valid and invalid cases
4. **Update documentation**:
   - Add to README.md in the appropriate category
   - Update API.md if it exists
   - Add entry to CHANGELOG.md
5. **Support message templating** with placeholders like `{min}`, `{max}`, `{value}`

### Flutter Integration
- Ensure validators work seamlessly with `TextFormField`
- Support both pure Dart and Flutter contexts
- Test validators in Flutter example app when adding UI-related validation

### Error Messages
- Provide clear, user-friendly error messages
- Support message customization through parameters
- Use global message configuration when available
- Include placeholders for dynamic values

### Custom Rules and Groups
- Support custom rule registration via `MayrValidationCore().registerRule()`
- Support validation groups via `MayrValidationCore().registerGroup()`
- Handle environment-aware behavior (dev vs production)

### Dependencies
- Keep dependencies minimal
- Avoid adding unnecessary external packages
- Only use well-maintained packages with good pub.dev scores
- Update dependencies carefully and test thoroughly

### Documentation
- Write clear dartdoc comments for all public APIs
- Include code examples in documentation
- Keep README.md up to date with new features
- Maintain CHANGELOG.md following semantic versioning
- Update CONTRIBUTING.md when changing development workflows

### Commit Messages
- Use clear, descriptive commit messages
- Follow conventional commit format when possible
- Reference issue numbers when applicable

### Pull Requests
- Ensure all tests pass before submitting
- Run formatter and analyzer
- Update documentation as needed
- Provide clear description of changes
- Link to related issues

### CI/CD
- All PRs must pass CI checks (tests, formatting, analysis)
- CI runs on GitHub Actions
- Workflow file: `.github/workflows/ci.yaml`

## Common Patterns

### Validator Method Template
```dart
/// [Description of what this validates]
///
/// [Optional: Additional details, examples, or constraints]
///
/// Example:
/// ```dart
/// MayrValidator('value').ruleName().run();
/// ```
MayrValidator ruleName([String? customMessage]) {
  _rules.add(() {
    if (value == null) return null;
    
    // Validation logic
    if (/* validation fails */) {
      return customMessage ?? 
             _core.getMessage('ruleName') ?? 
             'Default error message';
    }
    return null;
  });
  return this;
}
```

### Test Template
```dart
group('ruleName', () {
  test('should return null for valid values', () {
    expect(MayrValidator('valid').ruleName().run(), isNull);
  });

  test('should return error message for invalid values', () {
    final error = MayrValidator('invalid').ruleName().run();
    expect(error, isNotNull);
    expect(error, contains('expected text'));
  });

  test('should accept custom error message', () {
    const customMessage = 'Custom error';
    final error = MayrValidator('invalid').ruleName(customMessage).run();
    expect(error, equals(customMessage));
  });
});
```

## Package Structure
```
dart_validator/
├── lib/
│   ├── src/
│   │   ├── core/              # MayrValidationCore singleton
│   │   ├── validators/        # MayrValidator class
│   │   └── extensions/        # Extension methods
│   └── mayr_validator.dart    # Main library export
├── test/                      # Test files
├── example/
│   ├── mayr_validator_example.dart
│   └── flutter_example/       # Flutter example app
├── .github/
│   └── workflows/             # CI/CD workflows
└── docs/                      # Additional documentation
```

## Important Notes
- Always maintain backward compatibility when possible
- Follow semantic versioning for releases
- Keep the API fluent and chainable
- Ensure validators work in both Dart and Flutter contexts
- Support null safety throughout the codebase
- Test validators with various input types (null, empty, edge cases)
