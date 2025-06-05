import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/providers/cart_provider.dart';
import 'package:shop_com/providers/currency_provider.dart';
import 'package:shop_com/providers/order_provider.dart';
import 'package:shop_com/utils/util.dart';

import '../../../utils/widgets/button_widget.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/product_bag_item.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isProcessingOrder = false;
  final ValueNotifier<String> _couponCode = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref.read(cartProvider.notifier).fetchCart();
      },
    );
  }

  Future<void> _refreshCart() async {
    await ref.read(cartProvider.notifier).refresh();
  }

  Future<void> _handleCheckout() async {
    if (_isProcessingOrder) return;
    setState(() {
      _isProcessingOrder = true;
    });

    context.pushNamed('checkout', extra: _couponCode.value);

    // try {
    //   await ref.read(orderProvider.notifier).createOrder(
    //       couponCode: _couponCode.value.isNotEmpty ? _couponCode.value : null);
    //
    //   await ref.read(cartProvider.notifier).refresh();
    //   // await ref.read(orderProvider.notifier).refresh();
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content: Text('Đặt hàng thành công'),
    //       backgroundColor: Colors.green,
    //     ));
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text('Đặt hàng thất bại: ${e.toString()}'),
    //       backgroundColor: Colors.red,
    //     ));
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isProcessingOrder = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartProvider);
    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: state.cart.products!.isEmpty
                    ? state.isLoading
                        ? const LoadingWidget()
                        : _buildEmptyCart()
                    : RefreshIndicator(
                        onRefresh: _refreshCart,
                        child: ListView.separated(
                          itemCount: state.cart.products?.length ?? 0,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 28),
                          itemBuilder: (context, index) => ProductBagItem(
                              productId:
                                  state.cart.products?[index].productId ?? '',
                              index: index,
                              quantity: state.cart.products?[index].quantity,
                              variantIndex:
                                  state.cart.products?[index].variantIndex,
                              imageUrl: state.cart.products?[index]
                                  .variantProduct?[0].images?[0],
                              name: state.cart.products?[index].productName,
                              color: state.cart.products?[index]
                                  .variantProduct?[0].color,
                              ram: state
                                  .cart.products?[index].variantProduct?[0].ram,
                              rom: state
                                  .cart.products?[index].variantProduct?[0].rom,
                              price: state.cart.products?[index]
                                  .variantProduct?[0].price),
                        ),
                      ),
              ),

              const SizedBox(
                height: 10,
              ),

              // Promo code
              ValueListenableBuilder<String>(
                valueListenable: _couponCode,
                builder: (context, value, child) {
                  return TextField(
                    onChanged: (val) => _couponCode.value = val.trim(),
                    decoration: const InputDecoration(
                      hintText: 'Enter your promo code',
                      border: UnderlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: Icon(Icons.arrow_forward, color: Colors.grey),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total amount:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    formatMoney(state.cart.totalPrice ?? 0,
                        ref.watch(currencyProvider)),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: CommonButtonWidget(
                    callBack: state.cart.products!.isEmpty ? null : _handleCheckout,
                    label: _isProcessingOrder ? 'PROCESSING...' : 'CHECK OUT',
                    style: const TextStyle(color: Colors.white),
                    buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            (_isProcessingOrder || state.cart.products!.isEmpty) ? Colors.grey : Colors.black)),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshCart,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
