import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../data/config/app_config.dart';
import '../../../utils/widgets/input_form_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreen();
}

class _SignupScreen extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Center(
                  child: Text(
                    "Sign up",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Name',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400)),
                      TextFormField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.account_circle_outlined),
                            border: OutlineInputBorder(),
                            hintText: 'Enter name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _name = newValue!.trim();
                        },
                      ),
                      const SizedBox(height: 5),
                      const Text('Email',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400)),
                      TextFormField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                            hintText: 'Enter email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _email = newValue!.trim();
                        },
                      ),
                      const SizedBox(height: 5),
                      // Password field
                      const Text('Password',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400)),
                      TextFormField(
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Enter password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                icon: Icon(_passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password: ';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _password = newValue!.trim();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.goNamed('auth'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Already have an account?",
                            style: TextStyle(color: Colors.black87)),
                        Icon(Icons.arrow_right_alt, color: Colors.red),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("SIGNUP",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 30),
                // Or login with
                const Center(child: Text("Or sign up with social account")),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(FontAwesomeIcons.google, Colors.white),
                    const SizedBox(width: 20),
                    _socialButton(FontAwesomeIcons.facebook, Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final user = await api.signup(name: _name, email: _email, password: _password);
    if (mounted && user.isValue == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sign up success"),
        backgroundColor: Colors.green,
      ));
      reloadApiUrl();
      if (mounted) {
        context.goNamed("auth");
      }
      // Future.microtask(() => context.go("/tab1"));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sign up failed"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: FaIcon(icon, size: 28, color: Colors.black87),
    );
  }
}
