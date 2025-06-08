import 'dart:convert';

import 'package:shop_com/data/model/rating.dart';
import 'package:shop_com/data/model/variant.dart';
import 'package:shop_com/utils/util.dart';

class Product {
  String? id;
  String name;
  String? description;
  String? category;
  String? brand;
  Variant? defaultVariant;
  List<Variant>? variants;
  Ratings? ratings;
  bool? isActive;
  DateTime? createdAt;
  double? score;

  Product({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.brand,
    this.defaultVariant,
    this.variants,
    this.ratings,
    this.isActive,
    this.createdAt,
    this.score
  });

  factory Product.fromRawJson(String str) => Product.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Product.empty() => Product(name: '');

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["_id"],
      name: json["name"] ?? "Unknown",
      description: json["description"],
      category: json["category"],
      brand: json["brand"],
      defaultVariant: json["defaultVariant"] != null
          ? Variant.fromJson(json["defaultVariant"])
          : null,
      variants: json["variants"] != null
          ? List<Variant>.from(
        (json["variants"] as List).map(
              (x) => Variant.fromJson(x),
        ),
      )
          : [],
      ratings: json["ratings"] != null
          ? Ratings.fromJson(json["ratings"])
          : null,
      isActive: json["isActive"] ?? false,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      score: json["score"]?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "description": description,
    "category": category,
    "brand": brand,
    "defaultVariant": defaultVariant?.toJson(),
    "variants": List<dynamic>.from(variants!.map((x) => x.toJson())),
    "ratings": ratings?.toJson(),
    "isActive": isActive,
    "createdAt": getStringFromDateTime(createdAt ?? DateTime(0), 'dd/MM/yyyy'),
  };
}