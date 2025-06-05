import 'dart:convert';

import 'package:shop_com/data/model/product_cart.dart';

class Order {
  String? id;
  String? userId;
  List<ProductCart>? products;
  double? totalAmount;
  double? discountAmount;
  double? finalAmount;
  String? coupon;
  String? status;
  String? address;
  bool? isPaid;
  String? paymentMethod;
  DateTime? createdAt;

  int? v;

  Order({
    this.id,
    this.userId,
    this.products,
    this.totalAmount,
    this.discountAmount,
    this.finalAmount,
    this.coupon,
    this.status,
    this.address,
    this.isPaid,
    this.paymentMethod,
    this.createdAt,
    this.v,
  });

  factory Order.fromRawJson(String str) => Order.fromJson(json.decode(str));

  factory Order.empty() => Order();

  String toRawJson() => json.encode(toJson());

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["_id"],
    userId: json["userId"],
    products: List<ProductCart>.from(
        json["products"].map((x) => ProductCart.fromJson(x))),
    totalAmount: json["totalAmount"].toDouble(),
    discountAmount: json["discountAmount"].toDouble(),
    finalAmount: json["finalAmount"].toDouble(),
    coupon: json["coupon"],
    status: json["status"],
    address: json["address"],
    isPaid: json["isPaid"],
    paymentMethod: json["paymentMethod"],
    createdAt: DateTime.parse(json["createdAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "products": List<dynamic>.from(products!.map((x) => x.toJson())),
    "totalAmount": totalAmount,
    "status": status,
    "address": address,
    "paymentMethod": paymentMethod,
    "_id": id,
    "createdAt": createdAt?.toIso8601String(),
    "__v": v,
  };
}