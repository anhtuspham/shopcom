import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flag/flag.dart';

import '../../../data/config/app_config.dart';
import '../../../providers/currency_provider.dart';
import '../../../utils/widgets/button_widget.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header section
              _buildUserInfo(),
              const SizedBox(height: 24),

              // My Orders section
              Expanded(
                child: _buildOrderSection(ref),
              ),
              CommonButtonWidget(
                  callBack: () {
                    app_config.clearUser();
                    context.go('/login');
                  }, label: 'Đăng xuất')
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/person.jpg'),
        ),
        SizedBox(width: 20),
        Column(
          children: [
            Text(
              app_config.user?.name ?? '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              app_config.user?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildOrderSection(WidgetRef ref) {
    final menuItems = [
      {'title': 'Đơn hàng của tôi', 'trailing': ''},
      {'title': 'Địa chỉ giao hàng', 'trailing': ''},
      // {'title': 'Payment methods', 'trailing': 'Momo 0395****38'},
      // {'title': 'Promocodes', 'trailing': 'You have special promocodes'},
      // {'title': 'My reviews', 'trailing': 'Reviews for 4 items'},
      {'title': 'Đơn vị tiền tệ', 'trailing': 'USD'},
      // {'title': 'Settings', 'trailing': 'Notifications, password'},
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6),
        title: Text(
          menuItems[index]['title']!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w700,
          ),
        ),
        // subtitle: Text(
        //   menuItems[index]['trailing']!,
        //   style: TextStyle(
        //     color: Colors.grey[600],
        //     fontSize: 12,
        //   ),
        // ),
        trailing: menuItems[index]['title'] == 'Đơn vị tiền tệ'
            ? DropdownButton<Currency>(
                value: ref.watch(currencyProvider),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(currencyProvider.notifier).set(value);
                  }
                },
                items: Currency.values.map((cur) {
                  return DropdownMenuItem(
                      value: cur,
                      child: Row(
                        children: [
                          Flag.fromString(
                            cur == Currency.usd ? 'US' : 'VN',
                            height: 18,
                            width: 27,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(cur == Currency.usd ? 'USD' : 'VND')
                        ],
                      ));
                }).toList(),
              )
            : IconButton(
                onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios)),
        onTap: () {
          switch (index) {
            case 0:
              context.push('/order');
            case 1:
              context.push('/shippingAddress');
              break;
            case 2:
              // context.push('/setting');
              break;
          }
        },
      ),
    );
  }
}
