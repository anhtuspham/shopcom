import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/providers/order_detail_provider.dart';
import 'package:shop_com/providers/product_detail_provider.dart';
import 'package:shop_com/screens/account/screen/account_screen.dart';
import 'package:shop_com/screens/auth/screen/verify_otp_screen.dart';
import 'package:shop_com/screens/auth/screen/signup_screen.dart';
import 'package:shop_com/screens/cart/screen/cart_screen.dart';
import 'package:shop_com/screens/favorite/screen/favorite_screen.dart';
import 'package:shop_com/screens/product_detail/screen/product_detail_screen.dart';
import 'package:shop_com/screens/account/sub-screen/order_detail.dart';
import 'package:shop_com/screens/account/sub-screen/order_screen.dart';
import 'package:shop_com/screens/account/sub-screen/setting_screen.dart';
import 'package:shop_com/screens/account/sub-screen/shipping_address_screen.dart';
import 'package:shop_com/screens/product_detail/sub-screen/review_screen.dart';

import '../data/config/app_config.dart';
import '../data/model/auth_user.dart';
import '../data/model/product.dart';
import '../screens/home/home.dart';
import '../screens/auth/screen/login_screen.dart';
import '../screens/home/screen/dashboard_screen.dart';
import '../screens/shop/screen/shop_screen.dart';
import '../utils/widgets/error_page_widget.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

FutureOr<String?> systemRedirect(BuildContext context, GoRouterState state) {
  AuthUser? user = app_config.user;
  if (user == null) {
    if (state.fullPath!.compareTo("/auth") != 0 && state.fullPath != '/signup' && state.fullPath != '/verifyOtp') {
      return '/auth';
    }
  }
  return null;
}

GoRouter genRoute() {
  // List<MenuItem>? items = app_config.setupMenu;

  GoRoute screenLogin = GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      });

  GoRoute screenSignup = GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (BuildContext context, GoRouterState state) {
        return const SignupScreen();
      });

  GoRoute screenVerifyOtp = GoRoute(
    path: '/verifyOtp',
    name: 'verifyOtp',
    builder: (BuildContext context, GoRouterState state){
      final email = state.extra as String;
      return VerifyOtpScreen(email: email);
    }
  );

  List<GoRoute> groupHome = [];

  GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home',
      routes: [
        screenLogin,
        screenSignup,
        screenVerifyOtp,
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => HomeScreen(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/shop',
              name: 'shop',
              builder: (context, state) => const ShopScreen(),
            ),
            GoRoute(
              path: '/cart',
              name: 'cart',
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: '/favorite',
              name: 'favorite',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: '/account',
              name: 'account',
              builder: (context, state) => const AccountScreen(),
            ),
            GoRoute(
              path: '/setting',
              name: 'setting',
              builder: (context, state) => const SettingScreen(),
            ),
            GoRoute(
                path: '/shippingAddress',
                name: 'shippingAddress',
                builder: (context, state) => const ShippingAddress()),
            GoRoute(
              path: '/order',
              name: 'order',
              builder: (context, state) => const OrderScreen(),
            ),
            GoRoute(
              path: '/orderDetail',
              name: 'orderDetail',
              builder: (context, state) {
                final id = state.extra as String;
                return ProviderScope(overrides: [
                  orderDetailProvider.overrideWith(
                    (ref, arg) {
                      final notifier = OrderDetailNotifier();
                      notifier.fetchOrder(id);
                      return notifier;
                    },
                  )
                ], child: OrderDetailScreen(id: id));
              },
            ),
            GoRoute(
              path: '/productDetail',
              name: 'productDetail',
              builder: (context, state) {
                final id = state.extra as String;
                return ProviderScope(
                    overrides: [
                      productDetailProvider.overrideWith(
                        (ref, arg) {
                          final notifier = ProductDetailNotifier();
                          notifier.fetchProduct(id);
                          return notifier;
                        },
                      )
                    ],
                    child: ProductDetailScreen(
                      id: id,
                    ));
              },
            ),
            GoRoute(
              path: '/review',
              name: 'review',
              builder: (context, state) {
                final product = state.extra as Product;

                return ReviewScreen(product: product);
              },
            )
          ],
        ),
      ],
      redirect: systemRedirect,
      errorBuilder: (context, state) => const ErrorPageWidget());
  return router;
}
