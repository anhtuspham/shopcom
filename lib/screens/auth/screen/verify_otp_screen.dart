import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../data/config/app_config.dart';

int timeExpireOTP = 300;

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  int _remainingTime = timeExpireOTP;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_remainingTime > 0) {
          setState(() {
            _remainingTime--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  bool _isOtpComplete() {
    return _controllers
        .every((controller) => controller.text.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_outlined,
                  size: 80, color: Colors.green),
              const SizedBox(height: 15),
              const Text(
                'Xác thực OTP',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chúng tôi vừa gửi mã OTP thông qua email bạn vừa cung cấp',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                  '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 25)),
              const SizedBox(
                height: 8,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      height: 50,
                      width: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            counterText: '',
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15)),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(context)
                                .requestFocus(_focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .requestFocus(_focusNodes[index - 1]);
                          }
                        },
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  )),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không nhận được mã OTP'),
                  TextButton(
                      onPressed:
                          _remainingTime < (timeExpireOTP - 10) ? () {} : null,
                      child: const Text('Gửi lại mã OTP')),
                ],
              ),
              ElevatedButton(
                  onPressed: _isOtpComplete() == true
                      ? () async {
                          final otp = _controllers
                              .map((controller) => controller.text)
                              .join();
                          final result = await api.verifyOtpEmail(
                              email: widget.email, otp: otp);
                          if(!context.mounted) return;
                          if (mounted && result.isValue == true) {
                            if(!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Xác thực thành công, vui lòng đăng nhập"),
                              backgroundColor: Colors.green,
                            ));
                            reloadApiUrl();
                            if (mounted) {
                              context.goNamed("auth");
                            }
                            // Future.microtask(() => context.go("/tab1"));
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Xác thực OTP thất bại"),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward_ios),
                      SizedBox(width: 10),
                      Text('Xác thực')
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
