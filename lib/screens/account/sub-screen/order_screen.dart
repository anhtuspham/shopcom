import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/providers/order_provider.dart';
import 'package:shop_com/utils/util.dart';
import 'package:shop_com/utils/widgets/appbar_widget.dart';

import '../../../utils/widgets/loading_widget.dart';
import '../widgets/order_item.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref.read(orderProvider.notifier).fetchOrder();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const AppBarWidget(title: 'Đơn hàng của tôi'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      labelPadding: EdgeInsets.zero,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black,
                      ),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.w700),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(
                            child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Text('Đang chờ'),
                        )),
                        Tab(
                            child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Text('Đang xử lý'),
                        )),
                        Tab(
                            child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Text('Đã giao'),
                        )),
                        Tab(
                            child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Text('Hủy'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                        child: TabBarView(
                      children: [
                        _buildOrderItemSection(state, 'pending'),
                        _buildOrderItemSection(state, 'processing'),
                        _buildOrderItemSection(state, 'delivered'),
                        _buildOrderItemSection(state, 'cancelled')
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() {
    return ref.read(orderProvider.notifier).refresh();
  }

  Widget _buildOrderItemSection(OrderState state, String status) {
    if (state.isLoading) return const LoadingWidget();
    final filtered =
        state.orders?.where((element) => element.status == status).toList();
    if (filtered == null || filtered.isEmpty) return _buildEmptyOrderItemSection();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        itemBuilder: (context, index) {
          final order = filtered[index];
          return OrderItem(
            orderId: order.id,
            numberProducts: order.products?.length,
            orderStatus: order.status,
            orderTime: getStringFromDateTime(
                order.createdAt ?? DateTime.now(), 'HH:mm - dd/MM/yyyy'),
            totalAmount: order.finalAmount,
          );
        },
        itemCount: filtered.length,
        padding: const EdgeInsets.all(4),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }

  Widget _buildEmptyOrderItemSection() {
    return ListView.separated(
      itemBuilder: (context, index) => const Offstage(),
      itemCount: 0,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }
}
