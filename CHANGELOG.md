# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-10

### Added
- 🎉 Initial release of MayrValidations
- ✅ Core `MayrValidationCore` singleton for global configuration
- ✅ Fluent `MayrValidator` class for chainable validation
- ✅ Extension method `mayrValidator()` on String
- ✅ Comprehensive validation rules inspired by Laravel:
  - **Boolean validators**: `accepted()`, `boolean()`, `declined()`
  - **String validators**: `required()`, `min()`, `max()`, `email()`, `url()`, `alpha()`, `alphaNum()`, `alphaDash()`, `ascii()`, `lowercase()`, `uppercase()`, `regex()`, `notRegex()`, `startsWith()`, `endsWith()`, `doesntStartWith()`, `doesntEndWith()`, `uuid()`, `ulid()`, `ipAddress()`, `macAddress()`, `hexColor()`, `json()`, `inList()`, `notIn()`, `same()`, `different()`
  - **Number validators**: `numeric()`, `integer()`, `decimal()`, `between()`, `gt()`, `gte()`, `lt()`, `lte()`, `digits()`, `digitsBetween()`, `multipleOf()`
  - **Array validators**: `array()`, `contains()`, `doesntContain()`, `distinct()`
  - **Date validators**: `date()`, `after()`, `afterOrEqual()`, `before()`, `beforeOrEqual()`, `dateEquals()`
  - **Utility validators**: `nullable()`, `requiredIf()`, `requiredUnless()`
- ✅ Custom rule registration with `registerRule()`
- ✅ Validation group registration with `registerGroup()`
- ✅ Environment-aware error handling (dev vs prod)
- ✅ Global configuration for messages and defaults
- ✅ Message template support with placeholders (`{min}`, `{max}`, etc.)
- ✅ Debounce support for validation execution
- ✅ Comprehensive test suite with 71+ tests
- ✅ Pure Dart and Flutter examples
- ✅ Full documentation with dartdoc comments

### Features
- 🧩 **Fluent API** - Chain validation rules like Laravel
- ⚙️ **Global Configuration** - Define global defaults and messages
- 🔁 **Reusable Groups** - Register and reuse complex validation patterns
- 🧱 **Custom Validators** - Extend with your own validation logic
- ⚡ **Debounce Support** - Control when validations run
- 🧍‍♂️ **Standalone or Flutter-ready** - Works in pure Dart and Flutter

[1.0.0]: https://github.com/YoungMayor/mayr_dart_validator/releases/tag/v1.0.0

