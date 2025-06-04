import 'package:flutter/material.dart';
import 'package:shop_com/screens/home/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
