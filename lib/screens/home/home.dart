import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_com/screens/home/widgets/bottom_nav_bar.dart';

import '../../utils/color_value_key.dart';
import '../chatbot/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double posX = 20;
  double posY = 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          Positioned(
            left: posX,
            top: posY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  posX += details.delta.dx;
                  posY += details.delta.dy;
                });
              },
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => const ChatbotScreen(),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorValueKey.textColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 34),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
