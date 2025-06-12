import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/providers/currency_provider.dart';
import 'package:shop_com/providers/order_detail_provider.dart';
import 'package:shop_com/providers/order_provider.dart';
import 'package:shop_com/utils/util.dart';
import 'package:shop_com/utils/widgets/appbar_widget.dart';
import '../../../utils/widgets/button_widget.dart';
import '../../../utils/widgets/custom_header_info.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../widgets/order_product_item.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const OrderDetailScreen({super.key, required this.id});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final List statusOrder = ["pending", "processing", "delivered", "cancelled"];
  final List statusColor = [
    Colors.orange[600],
    Colors.blue[400],
    Colors.green[600],
    Colors.red[600]
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider(widget.id));
    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();

    return Scaffold(
      appBar: const AppBarWidget(title: 'Chi tiết đơn hàng'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(state),
                    const SizedBox(height: 24),
                    _buildOrderItems(state),
                    const SizedBox(height: 20),
                    _buildOrderInformation(state),
                    const SizedBox(height: 20),
                    state.order.status == 'pending' ? _buildButtonSection() : const SizedBox()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(OrderDetailState state) {
    return Column(
      children: [
        CustomHeaderInfo(title: 'OrderID', value: state.order.id ?? ''),
        CustomHeaderInfo(
            title: 'Thời gian đặt hàng',
            value: getStringFromDateTime(
                state.order.createdAt ?? DateTime.now(), 'HH:mm - dd/MM/yyyy')),
        CustomHeaderInfo(
          title: 'Trạng thái',
          value: upperCaseFirstLetter(state.order.status ?? ''),
          valueFontWeight: FontWeight.w700,
          valueColor: statusColor[statusOrder.indexOf(state.order.status)],
        )
      ],
    );
  }

  Widget _buildOrderItems(OrderDetailState state) {
    final items = List.generate(state.order.products?.length ?? 0, (index) {
      return OrderProductItem(
          index: index,
          imageUrl: state.order.products?[index].variantProduct?[0].images?[0],
          unit: state.order.products?[index].quantity.toString(),
          name: state.order.products?[index].productName,
          color: state.order.products?[index].variantProduct?[0].color,
          ram: state.order.products?[index].variantProduct?[0].ram,
          rom: state.order.products?[index].variantProduct?[0].rom,
          price: state.order.products?[index].price);
    });

    return Column(
      children: List.generate(
        items.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: items[index],
        ),
      ),
    );
  }

  Widget _buildOrderInformation(OrderDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin đơn hàng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        CustomHeaderInfo(
            title: 'Đại chỉ giao hàng',
            value: state.order.address ?? '',
            valueFontWeight: FontWeight.w700),
        SizedBox(height: 8),
        CustomHeaderInfo(
            title: 'Phương thức thanh toán',
            value: state.order.paymentMethod ?? '',
            valueFontWeight: FontWeight.w700),
        SizedBox(height: 8),
        const CustomHeaderInfo(
            title: 'Vận chuyển',
            value: 'Giao hàng nhanh',
            valueFontWeight: FontWeight.w700),
        const SizedBox(height: 8),
        CustomHeaderInfo(
            title: 'Tình trạng',
            value: state.order.isPaid == true
                ? 'Đã thanh toán'
                : 'Chưa thanh toán',
            valueFontWeight: FontWeight.w700),
        SizedBox(height: 8),
        CustomHeaderInfo(
            title: 'Tiền đơn hàng',
            value: formatMoney(
                state.order.totalAmount ?? 0, ref.watch(currencyProvider)),
            valueFontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        CustomHeaderInfo(
            title: 'Giảm giá',
            value:
                '-${formatMoney(state.order.discountAmount ?? 0, ref.watch(currencyProvider))}',
            valueFontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        CustomHeaderInfo(
          title: 'Tổng tiền',
          value: formatMoney(
              state.order.finalAmount ?? 0, ref.watch(currencyProvider)),
          valueFontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ],
    );
  }

  Widget _buildButtonSection() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 35,
        children: [
          Expanded(
            child: CommonButtonWidget(
                callBack: () async {
                  try {
                    await ref
                        .read(orderProvider.notifier)
                        .cancelOrder(orderId: widget.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Đơn hàng đã bị hủy'),
                      backgroundColor: Colors.green,
                    ));
                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Có lỗi khi hủy đơn hàng}'),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                label: 'Hủy đơn hàng',
                style: const TextStyle(color: Colors.white),
                buttonStyle: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red))),
          )
        ]);
  }

// Widget _buildButtonSection() {
//   return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       spacing: 35,
//       children: [
//         Expanded(
//           child: CommonButtonWidget(
//             callBack: () {},
//             label: 'Reorder',
//           ),
//         ),
//         Expanded(
//           child: CommonButtonWidget(
//               callBack: () {},
//               label: 'Leave feedback',
//               style: const TextStyle(color: Colors.white),
//               buttonStyle: const ButtonStyle(
//                   backgroundColor: WidgetStatePropertyAll(Colors.green))),
//         )
//       ]);
// }
}
