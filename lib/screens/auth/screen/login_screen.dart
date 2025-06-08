import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/data/config/app_config.dart';
import 'package:shop_com/providers/auth_provider.dart';

import '../../../utils/widgets/input_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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
                    "Đăng nhập",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                // Email field
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400)),
                      TextFormField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                            hintText: 'Nhập địa chỉ  email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập địa chỉ email';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _email = newValue!.trim();
                        },
                      ),
                      const SizedBox(height: 5),
                      // Password field
                      const Text('Mật khẩu',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400)),
                      TextFormField(
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Nhập mật khẩu',
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
                            return 'Vui lòng nhập mật khẩu: ';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _password = newValue!.trim();
                        },
                      ),
                      const SizedBox(height: 5),
                      // Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Quên mật khẩu?",
                                    style: TextStyle(color: Colors.black87)),
                                // Icon(Icons.arrow_right_alt, color: Colors.red),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              return context.goNamed('signup');
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Đăng ký tài khoản?",
                                    style: TextStyle(color: Colors.black87)),
                                Icon(Icons.arrow_right_alt, color: Colors.red),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("ĐĂNG NHẬP",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Or login with
                const Center(child: Text("Hoặc đăng nhập bằng tài khoản")),
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

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final user = await authProvider.login(_email, _password);
    if (mounted && user != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Đăng nhập thành công"),
        backgroundColor: Colors.green,
      ));
      reloadApiUrl();
      if (mounted) {
        context.goNamed("home", extra: true);
      }
      // Future.microtask(() => context.go("/tab1"));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Đăng nhập thất bại"),
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
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: FaIcon(icon, size: 28, color: Colors.black87),
    );
  }
}
