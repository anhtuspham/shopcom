import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/data/config/app_config.dart';
import 'package:shop_com/providers/user_provider.dart';
import 'package:shop_com/utils/widgets/appbar_widget.dart';

import '../../../providers/currency_provider.dart';
import '../../../utils/util.dart';
import '../../../utils/widgets/custom_header_info.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'cod';
  String _selectedDeliveryMethod = 'GHN';
  final List<Map<String, String>> paymentMethod = [
    {'label': 'Thanh toán khi nhận hàng', 'value': 'cod'},
    {'label': 'Thanh toán thẻ VISA', 'value': 'visa'},
    {'label': 'Thanh toán qua Momo', 'value': 'momo'},
  ];

  final List<Map<String, String>> deliveryMethod = [
    {'label': 'Giao hàng nhanh', 'value': 'GHN'},
  ];
  
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: const AppBarWidget(title: 'Check out'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildShippingSection(userAsync),
              const SizedBox(height: 20),
              _buildPaymentSection(),
              const SizedBox(
                height: 20,
              ),
              _buildDeliveryMethodSection(),
              const SizedBox(height: 20),
              _buildCheckoutInfo()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShippingSection(UserState userAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Địa chỉ giao hàng',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.25,
                fontSize: 19)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(color: Colors.grey)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      userAsync.user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    )),
                    TextButton(
                        onPressed: () => context.pushNamed('shippingAddress'),
                        child: const Text(
                          'Thay đổi',
                          style: TextStyle(color: Colors.redAccent),
                        ))
                  ],
                ),
                const SizedBox(height: 10),
                Text(userAsync.user.address ?? 'Trống...'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phương thức thanh toán',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.25,
                fontSize: 19)),
        const SizedBox(height: 8),
        Column(
            children: paymentMethod.map((payment) {
          return RadioListTile<String>(
            title: Text(payment['label'] ?? ''),
            value: payment['value'] ?? '',
            groupValue: _selectedPaymentMethod,
            contentPadding: EdgeInsets.zero,
            onChanged: (String? value) {
              setState(() {
                print('value: $value');
                _selectedPaymentMethod = value ?? 'cod';
              });
            },
          );
        }).toList())
      ],
    );
  }

  Widget _buildDeliveryMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Đơn vị vận chuyển',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.25,
                fontSize: 19)),
        const SizedBox(height: 8),
        Column(
            children: deliveryMethod.map((delivery) {
              return RadioListTile<String>(
                title: Text(delivery['label'] ?? ''),
                value: delivery['value'] ?? '',
                groupValue: _selectedDeliveryMethod,
                contentPadding: EdgeInsets.zero,
                onChanged: (String? value) {
                  setState(() {
                    _selectedDeliveryMethod = value ?? 'GHN';
                  });
                },
              );
            }).toList())
      ],
    );
  }

  Widget _buildCheckoutInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin đơn hàng',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.25,
                fontSize: 19)),
        SizedBox(height: 12),
        CustomHeaderInfo(
            title: 'Tổng tiền hàng',
            value: formatMoney(10, ref.watch(currencyProvider)),
            valueFontWeight: FontWeight.w700),
        SizedBox(height: 8),
        CustomHeaderInfo(
            title: 'Phí vận chuyển',
            value: formatMoney(1, ref.watch(currencyProvider)),
            valueFontWeight: FontWeight.w700),
        SizedBox(height: 8),
        CustomHeaderInfo(
            title: 'Thành tiền',
            value: formatMoney(12, ref.watch(currencyProvider)),
            valueFontWeight: FontWeight.w700),
      ],
    );
  }
}
