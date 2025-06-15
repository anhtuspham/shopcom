import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black,
      iconSize: 40,
      currentIndex: _getSelectedIndex(context),
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/shop');
            break;
          case 2:
            context.go('/cart');
            break;
          case 3:
            context.go('/favorite');
            break;
          case 4:
            context.go('/account');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cửa hàng"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Giỏ hàng"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Yêu thích"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
      ],
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location == '/home') return 0;
    if (location == '/shop') return 1;
    if (location == '/cart') return 2;
    if (location == '/favorite') return 3;
    if (location.startsWith('/account')) return 4;

    return 0;
  }
}
