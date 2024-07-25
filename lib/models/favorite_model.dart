class Favorites {
  Favorites({
    required this.productId,
    required this.picture,
    required this.category,
    required this.name,
    required this.price,
    required this.harvest,
    required this.stock,
    required this.createdDate,
    required this.productSize,
  });

  final int productId;
  final String picture;
  final String category;
  final String name;
  final double price;
  final int harvest;
  final int stock;
  final DateTime? createdDate;
  final int productSize;

  factory Favorites.fromJson(Map<String, dynamic> json) {
    return Favorites(
      productId: json["productId"],
      picture: json["picture"],
      category: json["category"],
      name: json["name"],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      harvest: json["harvest"],
      stock: json["stock"],
      createdDate: DateTime.tryParse(json["createdDate"] ?? ""),
      productSize: json['productSize'] != null
          ? int.parse(json['productSize'].toString())
          : 0,
    );
  }
}