import 'dart:convert';
// import 'dart:ffi';

class Variant {
  List<String>? images;
  String? color;
  String? ram;
  String? rom;
  double? price;
  int? quantity;
  String? id;

  Variant({
    this.images,
    this.color,
    this.ram,
    this.rom,
    this.price,
    this.quantity,
    this.id,
  });

  factory Variant.fromRawJson(String str) => Variant.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    images: List<String>.from(json["images"].map((x) => x)),
    color: json["color"],
    ram: json["ram"],
    rom: json["rom"],
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    quantity: json["quantity"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "images": List<dynamic>.from(images!.map((x) => x)),
    "color": color,
    "ram": ram,
    "rom": rom,
    "price": price,
    "quantity": quantity,
    "_id": id,
  };
}