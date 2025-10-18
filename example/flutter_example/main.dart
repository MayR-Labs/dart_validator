import 'package:flutter/material.dart';
import 'package:dart_validator/mayr_validator.dart';
import 'setup_validations.dart';

/// Flutter Example for MayrValidator
///
/// This example demonstrates how to use MayrValidator in a Flutter application
/// with TextFormField widgets.
///
/// To run this example:
/// 1. Create a new Flutter project
/// 2. Add mayr_validator to pubspec.yaml
/// 3. Copy this file to your project
/// 4. Run the app

void main() {
  // Setup global validation configuration before running the app
  setupValidations();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MayrValidator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Validation configuration is set up in main() via setupValidations()
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, process the data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Print form data
      print('Email: ${_emailController.text}');
      print('Username: ${_usernameController.text}');
      print('Age: ${_ageController.text}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MayrValidator Demo'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registration Form',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value.mayrValidator().required().email().max(100).run(),
              ),
              SizedBox(height: 16),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username *',
                  hintText:
                      'Enter username (3-20 chars, letters, numbers, -, _)',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value.mayrValidator().group('username').run(),
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Min 8 chars, uppercase, lowercase, number',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value.mayrValidator().group('strongPassword').run(),
              ),
              SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) => value
                    .mayrValidator()
                    .required()
                    .same(_passwordController.text, 'Passwords must match')
                    .run(),
              ),
              SizedBox(height: 16),

              // Age Field
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age *',
                  hintText: 'Enter your age (18-120)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value
                    .mayrValidator()
                    .required()
                    .numeric()
                    .between(18, 120)
                    .run(),
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Submit', style: TextStyle(fontSize: 16)),
              ),

              SizedBox(height: 16),

              // Info Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Validation Rules:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoRow(
                        'Email',
                        'Valid email format, max 100 chars',
                      ),
                      _buildInfoRow(
                        'Username',
                        '3-20 chars, letters, numbers, -, _',
                      ),
                      _buildInfoRow(
                        'Password',
                        'Min 8 chars, uppercase, lowercase, number',
                      ),
                      _buildInfoRow('Confirm Password', 'Must match password'),
                      _buildInfoRow('Age', 'Number between 18-120'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $label: ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Expanded(child: Text(description, style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

/// Example 2: Login Form
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      print('Login with: ${_emailController.text}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logging in...')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) => value
                    .mayrValidator()
                    .required('Email is required')
                    .email('Please enter a valid email')
                    .run(),
              ),
              SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) => value
                    .mayrValidator()
                    .required('Password is required')
                    .min(6, 'Password must be at least 6 characters')
                    .run(),
              ),

              // Remember me checkbox
              CheckboxListTile(
                title: Text('Remember me'),
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),

              SizedBox(height: 24),

              // Login button
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 3: Dynamic Form with Real-time Validation
class DynamicValidationForm extends StatefulWidget {
  @override
  _DynamicValidationFormState createState() => _DynamicValidationFormState();
}

class _DynamicValidationFormState extends State<DynamicValidationForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCountry = 'US';
  bool _requiresPostalCode = true;
  final _postalCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Validation')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Country selector
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: InputDecoration(labelText: 'Country'),
                items: [
                  DropdownMenuItem(value: 'US', child: Text('United States')),
                  DropdownMenuItem(value: 'UK', child: Text('United Kingdom')),
                  DropdownMenuItem(value: 'CA', child: Text('Canada')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                    _requiresPostalCode = value != 'UK';
                  });
                },
              ),
              SizedBox(height: 16),

              // Postal code with conditional validation
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: _requiresPostalCode
                      ? 'Postal Code *'
                      : 'Postal Code (Optional)',
                ),
                validator: (value) => value
                    .mayrValidator()
                    .requiredIf(
                      _requiresPostalCode,
                      'Postal code is required for this country',
                    )
                    .run(),
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Form is valid!')));
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
