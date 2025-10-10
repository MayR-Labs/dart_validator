# Contributing to MayrValidations

Thank you for your interest in contributing to MayrValidations! We welcome contributions from the community.

## 🤝 How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check if the issue already exists in [GitHub Issues](https://github.com/YoungMayor/mayr_dart_validator/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Dart/Flutter version
   - Code examples if applicable

### Pull Requests

We love pull requests! Here's how to contribute code:

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/mayr_dart_validator.git
   cd mayr_dart_validator
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add tests for new features
   - Update documentation as needed
   - Ensure all tests pass

4. **Run tests and analysis**
   ```bash
   dart analyze
   dart test
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add some feature"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/my-new-feature
   ```

7. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your feature branch
   - Provide a clear description of your changes

## 📝 Code Style Guidelines

### Dart Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Run `dart analyze` to check for issues

### Documentation

- Add dartdoc comments for public APIs
- Use complete sentences in comments
- Include code examples in documentation
- Update README.md if adding new features

### Testing

- Write tests for all new features
- Ensure existing tests still pass
- Aim for high test coverage
- Use descriptive test names

Example test structure:
```dart
group('Feature Name', () {
  test('should do something specific', () {
    // Arrange
    final validator = MayrValidator('test');
    
    // Act
    final result = validator.required().run();
    
    // Assert
    expect(result, isNull);
  });
});
```

## 🏗️ Project Structure

```
mayr_dart_validator/
├── lib/
│   ├── src/
│   │   ├── core/              # Core singleton and configuration
│   │   ├── validators/        # Main validator class
│   │   └── extensions/        # Extension methods
│   └── mayr_validator.dart    # Main library file
├── test/                      # Test files
├── example/                   # Example code
│   ├── mayr_validator_example.dart
│   └── flutter_example/       # Flutter examples
└── docs/                      # Additional documentation
```

## 🧪 Running Tests

Run all tests:
```bash
dart test
```

Run specific test file:
```bash
dart test test/mayr_validator_test.dart
```

Run tests with coverage:
```bash
dart test --coverage=coverage
```

## 📋 Adding New Validators

When adding a new validation rule:

1. **Add the method to `MayrValidator` class**
   ```dart
   /// Description of what this validates.
   MayrValidator myNewRule([String? message]) {
     _rules.add(() {
       if (value == null) return null;
       
       // Validation logic here
       if (/* validation fails */) {
         return message ?? _core.getMessage('myNewRule') ?? 'Default message';
       }
       return null;
     });
     return this;
   }
   ```

2. **Add tests**
   ```dart
   test('myNewRule - should validate correctly', () {
     expect(MayrValidator('valid').myNewRule().run(), isNull);
     expect(MayrValidator('invalid').myNewRule().run(), isNotNull);
   });
   ```

3. **Update documentation**
   - Add to `README.md` in the appropriate section
   - Add to `API.md` with examples
   - Update `CHANGELOG.md`

## 🎯 Feature Requests

Before implementing a new feature:

1. Open an issue to discuss it
2. Wait for feedback from maintainers
3. Get approval before starting work
4. Follow the contribution guidelines

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙋 Questions?

If you have questions:

- Open a [GitHub Discussion](https://github.com/YoungMayor/mayr_dart_validator/discussions)
- Check existing [Issues](https://github.com/YoungMayor/mayr_dart_validator/issues)
- Read the [Documentation](https://github.com/YoungMayor/mayr_dart_validator)

## 👥 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for everyone.

### Our Standards

- Be respectful and inclusive
- Be patient and kind
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Enforcement

Violations can be reported to the project maintainers. All complaints will be reviewed and investigated.

---

Thank you for contributing to MayrValidations! 🎉
