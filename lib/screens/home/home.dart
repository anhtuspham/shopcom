import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  double posY = 20;

  void _updatePosition(DragUpdateDetails details) {
    setState(() {
      double newPosX = posX + details.delta.dx;
      double newPosY = posY - details.delta.dy;

      final screenWidth = MediaQuery.of(context).size.width;
      posX = newPosX.clamp(0, screenWidth - 60);

      final screenHeight = MediaQuery.of(context).size.height;
      final bottomBarHeight = 60.0;
      posY = newPosY.clamp(0, screenHeight - bottomBarHeight - 60);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    final isHomePage = GoRouter.of(context).state.matchedLocation == '/home';
    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          Positioned(
            left: posX,
            bottom: posY,
            child: GestureDetector(
              onPanUpdate: _updatePosition,
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

          if (isHomePage)
            Positioned(
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () {
                  context.go('/coupon');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xem ưu đãi giảm giá!'), backgroundColor: Colors.green,),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent, // Màu nổi bật
                    borderRadius: BorderRadius.circular(20), // Bo góc
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_offer, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Voucher giảm giá',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
