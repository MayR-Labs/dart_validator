import 'package:mayr_validator/mayr_validator.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    // Reset core configuration before each test
    MayrValidationCore().reset();
  });

  group('MayrValidationCore', () {
    test('should be a singleton', () {
      final core1 = MayrValidationCore();
      final core2 = MayrValidationCore();
      expect(identical(core1, core2), isTrue);
    });

    test('should setup global configuration', () {
      final core = MayrValidationCore();
      core.setup({
        'messages': {'required': 'Custom required message'},
        'defaults': {'min': 5},
      });

      expect(core.getMessage('required'), equals('Custom required message'));
      expect(core.getDefault('min'), equals(5));
    });

    test('should register custom rules', () {
      final core = MayrValidationCore();
      core.registerRule('custom', (value, params) => null);
      expect(core.getCustomRule('custom'), isNotNull);
    });

    test('should register validation groups', () {
      final core = MayrValidationCore();
      core.registerGroup('username', (validator, params) => validator);
      expect(core.getGroup('username'), isNotNull);
    });
  });

  group('String Validators', () {
    test('required - should fail on null', () {
      final error = MayrValidator(null).required().run();
      expect(error, isNotNull);
    });

    test('required - should fail on empty string', () {
      final error = MayrValidator('').required().run();
      expect(error, isNotNull);
    });

    test('required - should pass on non-empty string', () {
      final error = MayrValidator('test').required().run();
      expect(error, isNull);
    });

    test('min - should fail when too short', () {
      final error = MayrValidator('ab').min(3).run();
      expect(error, isNotNull);
    });

    test('min - should pass when long enough', () {
      final error = MayrValidator('abc').min(3).run();
      expect(error, isNull);
    });

    test('max - should fail when too long', () {
      final error = MayrValidator('abcd').max(3).run();
      expect(error, isNotNull);
    });

    test('max - should pass when short enough', () {
      final error = MayrValidator('abc').max(3).run();
      expect(error, isNull);
    });

    test('email - should validate correct email', () {
      final error = MayrValidator('test@example.com').email().run();
      expect(error, isNull);
    });

    test('email - should fail on invalid email', () {
      final error = MayrValidator('invalid-email').email().run();
      expect(error, isNotNull);
    });

    test('url - should validate correct URL', () {
      final error = MayrValidator('https://example.com').url().run();
      expect(error, isNull);
    });

    test('url - should fail on invalid URL', () {
      final error = MayrValidator('not-a-url').url().run();
      expect(error, isNotNull);
    });

    test('alpha - should validate alphabetic characters', () {
      final error = MayrValidator('abc').alpha().run();
      expect(error, isNull);
    });

    test('alpha - should fail on non-alphabetic characters', () {
      final error = MayrValidator('abc123').alpha().run();
      expect(error, isNotNull);
    });

    test('alphaNum - should validate alphanumeric characters', () {
      final error = MayrValidator('abc123').alphaNum().run();
      expect(error, isNull);
    });

    test('alphaNum - should fail on special characters', () {
      final error = MayrValidator('abc-123').alphaNum().run();
      expect(error, isNotNull);
    });

    test(
      'alphaDash - should validate letters, numbers, dashes, underscores',
      () {
        final error = MayrValidator('abc_123-def').alphaDash().run();
        expect(error, isNull);
      },
    );

    test('lowercase - should validate lowercase string', () {
      final error = MayrValidator('abc').lowercase().run();
      expect(error, isNull);
    });

    test('lowercase - should fail on uppercase', () {
      final error = MayrValidator('ABC').lowercase().run();
      expect(error, isNotNull);
    });

    test('uppercase - should validate uppercase string', () {
      final error = MayrValidator('ABC').uppercase().run();
      expect(error, isNull);
    });

    test('uppercase - should fail on lowercase', () {
      final error = MayrValidator('abc').uppercase().run();
      expect(error, isNotNull);
    });

    test('regex - should validate pattern match', () {
      final error = MayrValidator('abc123').regex(r'^[a-z0-9]+$').run();
      expect(error, isNull);
    });

    test('regex - should fail on pattern mismatch', () {
      final error = MayrValidator('ABC').regex(r'^[a-z]+$').run();
      expect(error, isNotNull);
    });

    test('startsWith - should validate string prefix', () {
      final error = MayrValidator('hello world').startsWith('hello').run();
      expect(error, isNull);
    });

    test('endsWith - should validate string suffix', () {
      final error = MayrValidator('hello world').endsWith('world').run();
      expect(error, isNull);
    });

    test('uuid - should validate correct UUID', () {
      final error = MayrValidator(
        '550e8400-e29b-41d4-a716-446655440000',
      ).uuid().run();
      expect(error, isNull);
    });

    test('uuid - should fail on invalid UUID', () {
      final error = MayrValidator('not-a-uuid').uuid().run();
      expect(error, isNotNull);
    });
  });

  group('Number Validators', () {
    test('numeric - should validate numbers', () {
      expect(MayrValidator(123).numeric().run(), isNull);
      expect(MayrValidator('123').numeric().run(), isNull);
      expect(MayrValidator('abc').numeric().run(), isNotNull);
    });

    test('integer - should validate integers', () {
      expect(MayrValidator(123).integer().run(), isNull);
      expect(MayrValidator('123').integer().run(), isNull);
      expect(MayrValidator(123.45).integer().run(), isNotNull);
    });

    test('decimal - should validate decimals', () {
      expect(MayrValidator(123.45).decimal().run(), isNull);
      expect(MayrValidator('123.45').decimal().run(), isNull);
    });

    test('between - should validate range', () {
      expect(MayrValidator(5).between(1, 10).run(), isNull);
      expect(MayrValidator(0).between(1, 10).run(), isNotNull);
      expect(MayrValidator(11).between(1, 10).run(), isNotNull);
    });

    test('gt - should validate greater than', () {
      expect(MayrValidator(6).gt(5).run(), isNull);
      expect(MayrValidator(5).gt(5).run(), isNotNull);
      expect(MayrValidator(4).gt(5).run(), isNotNull);
    });

    test('gte - should validate greater than or equal', () {
      expect(MayrValidator(6).gte(5).run(), isNull);
      expect(MayrValidator(5).gte(5).run(), isNull);
      expect(MayrValidator(4).gte(5).run(), isNotNull);
    });

    test('lt - should validate less than', () {
      expect(MayrValidator(4).lt(5).run(), isNull);
      expect(MayrValidator(5).lt(5).run(), isNotNull);
      expect(MayrValidator(6).lt(5).run(), isNotNull);
    });

    test('lte - should validate less than or equal', () {
      expect(MayrValidator(4).lte(5).run(), isNull);
      expect(MayrValidator(5).lte(5).run(), isNull);
      expect(MayrValidator(6).lte(5).run(), isNotNull);
    });

    test('digits - should validate exact digit count', () {
      expect(MayrValidator(123).digits(3).run(), isNull);
      expect(MayrValidator(12).digits(3).run(), isNotNull);
    });

    test('multipleOf - should validate multiples', () {
      expect(MayrValidator(10).multipleOf(5).run(), isNull);
      expect(MayrValidator(11).multipleOf(5).run(), isNotNull);
    });
  });

  group('Boolean Validators', () {
    test('boolean - should validate boolean type', () {
      expect(MayrValidator(true).boolean().run(), isNull);
      expect(MayrValidator(false).boolean().run(), isNull);
      expect(MayrValidator('true').boolean().run(), isNotNull);
    });

    test('accepted - should validate accepted values', () {
      expect(MayrValidator(true).accepted().run(), isNull);
      expect(MayrValidator('yes').accepted().run(), isNull);
      expect(MayrValidator('1').accepted().run(), isNull);
      expect(MayrValidator(1).accepted().run(), isNull);
      expect(MayrValidator(false).accepted().run(), isNotNull);
    });

    test('declined - should validate declined values', () {
      expect(MayrValidator(false).declined().run(), isNull);
      expect(MayrValidator('no').declined().run(), isNull);
      expect(MayrValidator('0').declined().run(), isNull);
      expect(MayrValidator(0).declined().run(), isNull);
      expect(MayrValidator(true).declined().run(), isNotNull);
    });
  });

  group('Array Validators', () {
    test('array - should validate lists', () {
      expect(MayrValidator([1, 2, 3]).array().run(), isNull);
      expect(MayrValidator('not-array').array().run(), isNotNull);
    });

    test('contains - should validate list contains value', () {
      expect(MayrValidator([1, 2, 3]).contains(2).run(), isNull);
      expect(MayrValidator([1, 2, 3]).contains(4).run(), isNotNull);
    });

    test('distinct - should validate unique elements', () {
      expect(MayrValidator([1, 2, 3]).distinct().run(), isNull);
      expect(MayrValidator([1, 2, 2]).distinct().run(), isNotNull);
    });
  });

  group('Date Validators', () {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    final tomorrow = now.add(Duration(days: 1));

    test('date - should validate date types', () {
      expect(MayrValidator(now).date().run(), isNull);
      expect(MayrValidator('2023-01-01').date().run(), isNull);
      expect(MayrValidator('invalid-date').date().run(), isNotNull);
    });

    test('after - should validate date is after', () {
      expect(MayrValidator(tomorrow).after(now).run(), isNull);
      expect(MayrValidator(yesterday).after(now).run(), isNotNull);
    });

    test('before - should validate date is before', () {
      expect(MayrValidator(yesterday).before(now).run(), isNull);
      expect(MayrValidator(tomorrow).before(now).run(), isNotNull);
    });

    test('dateEquals - should validate date equality', () {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 1, 1);
      expect(MayrValidator(date1).dateEquals(date2).run(), isNull);
    });
  });

  group('Custom Rules and Groups', () {
    test('custom - should execute registered custom rule', () {
      final core = MayrValidationCore();
      core.registerRule('testRule', (value, params) {
        if (value == 'valid') return null;
        return 'Invalid value';
      });

      expect(MayrValidator('valid').custom('testRule').run(), isNull);
      expect(MayrValidator('invalid').custom('testRule').run(), isNotNull);
    });

    test('custom - should throw in development mode if rule not found', () {
      expect(
        () => MayrValidator('test').custom('nonexistent').run(),
        throwsException,
      );
    });

    test('group - should execute validation group', () {
      final core = MayrValidationCore();
      core.registerGroup('username', (validator, params) {
        return validator.required().min(3).max(20);
      });

      expect(MayrValidator('john').group('username').run(), isNull);
      expect(MayrValidator('ab').group('username').run(), isNotNull);
    });

    test('group - should throw in development mode if group not found', () {
      expect(
        () => MayrValidator('test').group('nonexistent').run(),
        throwsException,
      );
    });
  });

  group('Chaining Validators', () {
    test('should chain multiple validators', () {
      final error = MayrValidator(
        'test@example.com',
      ).required().email().min(5).max(50).run();
      expect(error, isNull);
    });

    test('should return first error in chain', () {
      final error = MayrValidator('ab').required().min(3).max(10).run();
      expect(error, isNotNull);
      expect(error, contains('min'));
    });
  });

  group('Extension Method', () {
    test('should work with string extension', () {
      final error = 'test@example.com'.mayrValidator().required().email().run();
      expect(error, isNull);
    });

    test('should work with null string', () {
      String? nullString;
      final error = nullString.mayrValidator().required().run();
      expect(error, isNotNull);
    });
  });

  group('Custom Messages', () {
    test('should use custom message from parameter', () {
      final error = MayrValidator('').required('Custom error').run();
      expect(error, equals('Custom error'));
    });

    test('should use custom message from config', () {
      final core = MayrValidationCore();
      core.setup({
        'messages': {'required': 'Config error message'},
      });

      final error = MayrValidator('').required().run();
      expect(error, equals('Config error message'));
    });

    test('should support parameter placeholders', () {
      final core = MayrValidationCore();
      core.setup({
        'messages': {'min': 'Must be at least {min} characters'},
      });

      final error = MayrValidator('ab').min(5).run();
      expect(error, contains('5'));
    });
  });

  group('Complex Validators', () {
    test('ipAddress - should validate IPv4', () {
      expect(MayrValidator('192.168.1.1').ipAddress().run(), isNull);
      expect(MayrValidator('256.1.1.1').ipAddress().run(), isNotNull);
    });

    test('macAddress - should validate MAC address', () {
      expect(MayrValidator('00:1B:44:11:3A:B7').macAddress().run(), isNull);
      expect(MayrValidator('invalid-mac').macAddress().run(), isNotNull);
    });

    test('hexColor - should validate hex colors', () {
      expect(MayrValidator('#FF5733').hexColor().run(), isNull);
      expect(MayrValidator('#F57').hexColor().run(), isNull);
      expect(MayrValidator('invalid').hexColor().run(), isNotNull);
    });

    test('json - should validate JSON strings', () {
      expect(MayrValidator('{"key":"value"}').json().run(), isNull);
      expect(MayrValidator('[1,2,3]').json().run(), isNull);
      expect(MayrValidator('invalid json').json().run(), isNotNull);
    });
  });

  group('Conditional Validators', () {
    test('requiredIf - should require when condition is true', () {
      expect(MayrValidator('').requiredIf(true).run(), isNotNull);
      expect(MayrValidator('').requiredIf(false).run(), isNull);
    });

    test('requiredUnless - should require unless condition is true', () {
      expect(MayrValidator('').requiredUnless(false).run(), isNotNull);
      expect(MayrValidator('').requiredUnless(true).run(), isNull);
    });
  });

  group('Comparison Validators', () {
    test('same - should validate equal values', () {
      expect(MayrValidator('test').same('test').run(), isNull);
      expect(MayrValidator('test').same('other').run(), isNotNull);
    });

    test('different - should validate different values', () {
      expect(MayrValidator('test').different('other').run(), isNull);
      expect(MayrValidator('test').different('test').run(), isNotNull);
    });

    test('inList - should validate value in list', () {
      expect(
        MayrValidator('red').inList(['red', 'green', 'blue']).run(),
        isNull,
      );
      expect(
        MayrValidator('yellow').inList(['red', 'green', 'blue']).run(),
        isNotNull,
      );
    });

    test('notIn - should validate value not in list', () {
      expect(
        MayrValidator('yellow').notIn(['red', 'green', 'blue']).run(),
        isNull,
      );
      expect(
        MayrValidator('red').notIn(['red', 'green', 'blue']).run(),
        isNotNull,
      );
    });
  });
}
