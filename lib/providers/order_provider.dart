import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/config/app_config.dart';
import '../data/model/order.dart';

class OrderState {
  final List<Order>? orders;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const OrderState({
    this.orders,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  factory OrderState.initial() => const OrderState();

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState.initial());

  Future<void> fetchOrder() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final orders = await api.fetchOrder();
      state = state.copyWith(orders: orders, isLoading: false, isError: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    await _updateOrderState();
  }

  Future<void> createOrder({String? paymentMethod, String? couponCode}) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final result = await api.createOrder(paymentMethod: paymentMethod, couponCode: couponCode);

      if (result.isValue) {
        await api.fetchCart();
        await _updateOrderState();
      } else {
        app_config.printLog("e", " API_CREATE_ORDER : ${result.asError?.error} ");
        throw Exception("Failed to create order: ${result.asError?.error}");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> cancelOrder({required String orderId}) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final result = await api.cancelOrder(orderId: orderId);
      if (result.isValue) {
        await api.fetchCart();
        await _updateOrderState();
      } else {
        app_config.printLog("e", " API_CANCEL_ORDER : ${result.asError?.error} ");
        throw Exception("Failed to cancel order: ${result.asError?.error}");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _updateOrderState() async{
    try{
      final order = await api.fetchOrder();
      state = state.copyWith(orders: order, isLoading: false);
    } catch(e){
      state = state.copyWith(isLoading: false, isError: true, errorMessage: e.toString());
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final notifier = OrderNotifier();
  notifier.fetchOrder();
  return notifier;
});