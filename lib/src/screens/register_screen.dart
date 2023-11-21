import 'package:code_challenge/src/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';
import '../../main.dart';
import '../globals.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final Map<String, bool> fieldTouched = {
    'name': false,
    'email': false,
    'password': false,
    'confirmPassword': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (fieldTouched['name'] == true &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {
                    fieldTouched['name'] = true;
                  });
                  _formKey.currentState?.validate();
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (fieldTouched['email'] == true &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter your email';
                  } else if (value != null &&
                      !RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
                          .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
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
                  if (fieldTouched['password'] == true &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter your password';
                  }
                  // Add password validation logic if needed
                  return null;
                },
                onChanged: (_) {
                  setState(() {
                    fieldTouched['password'] = true;
                  });
                  _formKey.currentState?.validate();
                },
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                validator: (value) {
                  if (fieldTouched['confirmPassword'] == true &&
                      (value == null || value.isEmpty)) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {
                    fieldTouched['confirmPassword'] = true;
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

                      final name = nameController.text;
                      final email = emailController.text;
                      final password = passwordController.text;
                      final confirmPassword = confirmPasswordController.text;

                      await authService.register(name, email, password, confirmPassword).then((value) {
                        OverlayLoadingProgress.stop();

                        if (value) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyAppHomePage()),
                          );
                        } else {
                          snackbarKey.currentState?.showSnackBar(const SnackBar(
                              content: Text("Failed to register"),
                              backgroundColor: Colors.red));
                        }
                      });
                    } catch (e) {
                      OverlayLoadingProgress.stop();
                      throw Exception(e);
                    }
                  }
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Already have an account? Login here')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
