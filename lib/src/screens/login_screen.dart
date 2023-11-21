import 'package:code_challenge/main.dart';
import 'package:code_challenge/src/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';
import '../globals.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final Map<String, bool> fieldTouched = {
    'email': false,
    'password': false,
  };

  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

  String? validateEmail(String? value) {
    if (fieldTouched['email'] == true && (value == null || value.isEmpty)) {
      return 'Please enter your email';
    } else if (value != null && !emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (fieldTouched['password'] == true && (value == null || value.isEmpty)) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  return validateEmail(value);
                },
                onChanged: (_) {
                  setState(() {
                    fieldTouched['email'] = true;
                  });
                  _formKey.currentState?.validate();
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  return validatePassword(value);
                },
                onChanged: (_) {
                  setState(() {
                    fieldTouched['password'] = true;
                  });
                  _formKey.currentState?.validate();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    fieldTouched.forEach((key, value) {
                      fieldTouched[key] = true;
                    });
                  });

                  if (_formKey.currentState?.validate() == true) {
                    final authService = AuthService(
                        'https://9c0f-197-237-124-4.ngrok-free.app');

                    try {
                      OverlayLoadingProgress.start(context);
                      final email = emailController.text;
                      final password = passwordController.text;

                      await authService.login(email, password).then((value) {
                        OverlayLoadingProgress.stop();

                        if (value) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const MyAppHomePage()),
                          );
                        } else {
                          snackbarKey.currentState?.showSnackBar(const SnackBar(
                              content: Text("Failed to login"),
                              backgroundColor: Colors.red));
                        }
                      });
                    } catch (e) {
                      OverlayLoadingProgress.stop();
                      throw Exception(e);
                    }
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the register screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(), // Replace RegisterScreen with your actual register screen widget
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
