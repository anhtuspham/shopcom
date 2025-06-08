import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/data/config/app_config.dart';
import 'package:shop_com/providers/coupon_provider.dart';
import 'package:shop_com/providers/user_provider.dart';
import 'package:shop_com/utils/widgets/appbar_widget.dart';

import '../../../providers/cart_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../utils/util.dart';
import '../../../utils/widgets/button_widget.dart';
import '../../../utils/widgets/custom_header_info.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String couponCode;
  const CheckoutScreen({super.key, required this.couponCode});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'COD';
  String _selectedDeliveryMethod = 'GHN';
  bool _isProcessingOrder = false;
  final List<Map<String, String>> paymentMethod = [
    {'label': 'Thanh toán khi nhận hàng', 'value': 'COD'},
    {'label': 'Thanh toán thẻ VISA', 'value': 'VISA'},
    // {'label': 'Thanh toán qua Momo', 'value': 'MOMO'},
  ];

  final List<Map<String, String>> deliveryMethod = [
    {'label': 'Giao hàng nhanh', 'value': 'GHN'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.couponCode.isNotEmpty){
        ref.read(couponProvider.notifier).getCoupon(couponCode: widget.couponCode);
      }
    },);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final currency = ref.watch(currencyProvider);
    final coupon = ref.watch(couponProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: const AppBarWidget(title: 'Thanh toán'),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
                      _buildCheckoutInfo(cart, coupon),
                      const SizedBox(height: 20),
                      const Spacer(),
                      SizedBox(
                          width: double.infinity,
                          child: CommonButtonWidget(
                            callBack: _isProcessingOrder ? null : _handleSubmitOrder,
                            label: _isProcessingOrder
                                ? 'Đang xử lý...'
                                : 'Đặt hàng',
                            style: const TextStyle(color: Colors.white),
                            buttonStyle: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    (_isProcessingOrder)
                                        ? Colors.grey
                                        : Colors.black)),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
                _selectedPaymentMethod = value ?? 'COD';
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

  Widget _buildCheckoutInfo(CartState cart, CouponState coupon) {
    final originalPrice = cart.cart.totalPrice;

    double discount = 0;
    if (coupon.couponDetail != null) {
      final current = coupon.couponDetail!;
      if (current.discountType == 'percentage') {
        discount = ((originalPrice ?? 0) * (current.discountValue as num)/ 100).toDouble();
        if (current.maxDiscountAmount != null && discount > current.maxDiscountAmount!) {
          discount = current.maxDiscountAmount!.toDouble();
        }
      } else if (current.discountType == 'fixed') {
        discount = current.discountValue?.toDouble() ?? 0;
      }

      if (current.minOrderValue != null && originalPrice! < current.minOrderValue!) {
        discount = 0;
      }
    }

    final finalPrice = (originalPrice ?? 0) - discount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thông tin đơn hàng',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.25,
                fontSize: 19)),
        const SizedBox(height: 12),
        CustomHeaderInfo(
            title: 'Tổng tiền hàng',
            value: formatMoney(cart.cart.totalPrice ?? 0, ref.watch(currencyProvider)),
            valueFontWeight: FontWeight.w700),
        const SizedBox(height: 8),
        CustomHeaderInfo(title: 'Giảm giá', value: formatMoney(discount, ref.watch(currencyProvider)), valueFontWeight: FontWeight.w700,),
        const SizedBox(height: 8),
        const CustomHeaderInfo(
            title: 'Phí vận chuyển',
            // value: formatMoney(1, ref.watch(currencyProvider)),
            value: 'Miễn phí',
            valueFontWeight: FontWeight.w700),
        const SizedBox(height: 8),
        CustomHeaderInfo(
            title: 'Thành tiền',
            value: formatMoney(finalPrice, ref.watch(currencyProvider)),
            valueFontWeight: FontWeight.w700),
      ],
    );
  }
  Future<void> _handleSubmitOrder() async {
    if (_isProcessingOrder) return;

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      if (ref.read(userProvider).user.address == null || ref.read(userProvider).user.address!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cập nhật địa chỉ giao hàng')),
        );
        setState(() => _isProcessingOrder = false);
        return;
      }

      if (_selectedPaymentMethod == 'VISA') {
        await _makePayment(context);
      } else {
        // Handle other payment methods (e.g., COD, Momo)
        final result = await api.createOrder(paymentMethod: _selectedPaymentMethod, couponCode: widget.couponCode);
        if (result.isValue) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đơn hàng đã được tạo thành công')),
          );
          context.go('/order'); // Navigate to orders screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi tạo đơn hàng: ${result.asError!.error}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }


  Future<void> _makePayment(BuildContext context) async {
    final cart = ref.watch(cartProvider);
    final coupon = ref.watch(couponProvider);
    try {
      // Use the total amount from checkout info (in cents)
      double finalAmount = _calculateFinalPrice(cart, coupon);
      print('finalAmount $finalAmount');

      // double totalAmount = (cart.cart.totalPrice ?? 0);
      final currency = ref.watch(currencyProvider).name ?? 'usd';
      if(currency == 'vnd') finalAmount = (finalAmount * 25980).roundToDouble();
      if(currency == 'usd') finalAmount = (finalAmount * 100).roundToDouble();
      final paymentIntentData = await api.createPaymentIntent(finalAmount, currency);

      if (kDebugMode) {
        print('PaymentIntent response: $paymentIntentData');
      }

      if (paymentIntentData == null || paymentIntentData['clientSecret'] == null) {
        throw Exception('Không thể tạo PaymentIntent: response is null');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Thanh toán qua Stripe',
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
          style: ThemeMode.dark,
          // paymentMethodOrder: ['card'], // Explicitly specify card payment
        ),
      );

      await _displayPaymentSheet(context);
    } catch (e) {
      if (kDebugMode) {
        print('Payment error: ${e.toString()}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thanh toán: $e')),
      );
      rethrow;
    }
  }

  Future<void> _displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán thành công')),
      );
      // Create order after successful payment
      final result = await api.createOrder(paymentMethod: _selectedPaymentMethod, couponCode: widget.couponCode, isPaid: true);
      if (result.isValue) {
        context.go('/order'); // Navigate to orders screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo đơn hàng: ${result.asError!.error}')),
        );
      }
    } on StripeException catch (e) {
      if (kDebugMode) {
        print('Stripe error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thanh toán: ${e.error.localizedMessage}')),
      );
    }
  }
  double _calculateFinalPrice(CartState cart, CouponState coupon) {
    final originalPrice = cart.cart.totalPrice ?? 0;
    double discount = 0;

    if (coupon.couponDetail != null) {
      final current = coupon.couponDetail!;
      if (current.minOrderValue != null && originalPrice < current.minOrderValue!) {
        return originalPrice;
      }
      if (current.discountType == 'percentage') {
        discount = (originalPrice * current.discountValue! / 100);
        if (current.maxDiscountAmount != null && discount > current.maxDiscountAmount!) {
          discount = current.maxDiscountAmount!.toDouble();
        }
      } else if (current.discountType == 'fixed') {
        discount = current.discountValue?.toDouble() ?? 0;
      }
    }

    return originalPrice - discount;
  }

}
