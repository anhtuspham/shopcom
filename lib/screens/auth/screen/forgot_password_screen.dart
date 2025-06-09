import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/data/config/app_config.dart';
import 'package:shop_com/providers/auth_provider.dart';

import '../../../data/model/verify.dart';
import '../../../utils/widgets/input_form_widget.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

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
                    "Quên mật khẩu",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Vui lòng nhập địa chỉ email để lấy lại mật khẩu'),
                const SizedBox(height: 10),
                // Email field
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text('Email',
                      //     style: TextStyle(
                      //         fontSize: 15, fontWeight: FontWeight.w400)),
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
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.goNamed('login'),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Bạn đã có tài khoản?",
                                  style: TextStyle(color: Colors.black87)),
                              Icon(Icons.arrow_right_alt, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Forgot Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onForgot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("GỬI",
                              style:
                              TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onForgot() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final user = await api.forgotPassword(email: _email);
    if (mounted && user != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Mã xác minh đã được gửi"),
        backgroundColor: Colors.green,
      ));
      reloadApiUrl();
      if (mounted) {
        context.goNamed("verifyOtp", extra: Verify(email: _email, isVerifyEmail: false));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Tài khoản không tồn tại"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
