import 'package:flutter/material.dart';
import 'package:shop_com/screens/home/widgets/bottom_nav_bar.dart';

import '../chatbot/chatbot_screen.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => const ChatbotScreen(),
          );
        },
        // backgroundColor: ColorValueKey.textColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
