import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:shop_com/apis/base_api.dart';

import '../data/config/app_config.dart';
import '../data/model/cart.dart';
import '../data/model/order.dart';

mixin OrderApi on BaseApi {
  Future<List<Order>> fetchOrder() async {
    Result result = await handleRequest(request: () {
      return get('/api/order/my-orders');
    });

    try {
      List rawList = result.asValue!.value;
      return safeParseOrders(rawList);
    } catch (e) {
      return [];
    }
  }

  List<Order> safeParseOrders(List rawList) {
    return rawList
        .map<Order?>((e) {
          try {
            return Order.fromJson(e);
          } catch (err) {
            app_config.printLog(
                "e", " API_USER_FETCH_ORDER : ${err.toString()} \n Item: $e");
            // print('❌ Lỗi khi parse product: $err\nRaw item: $e');
            return null;
          }
        })
        .whereType<Order>()
        .toList();
  }

  Future<Result> createOrder(
      {String? paymentMethod, String? couponCode, bool? isPaid}) async {
    return handleRequest(
        request: () => post('/api/order', data: {
              "paymentMethod": paymentMethod,
              "couponCode": couponCode,
              "isPaid": isPaid
            }));
  }

  Future<Result> cancelOrder({required String orderId}) async {
    return handleRequest(request: () => delete('/api/order/$orderId/cancel'));
  }

  Future<Order> fetchOrderDetail({required String orderId}) async {
    Result result = await handleRequest(request: () async {
      return get('/api/order/get-order/$orderId');
    });
    try {
      return Order.fromJson(result.asValue!.value);
    } catch (_) {
      return Order.empty();
    }
  }

  dynamic createPaymentIntent(double amount, String currency) async {
    Result result = await handleRequest(
      request: () => post('/api/order/create-payment-intent',
          data: {'amount': amount, 'currency': currency}),
    );

    try {
      if (result.isValue) {
        return result.asValue!.value;
      } else {
        throw Exception(
            'Failed to create PaymentIntent: ${result.asError!.error}');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }
}
