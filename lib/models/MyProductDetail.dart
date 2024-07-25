class ProductUpdate {
  final int productId;
  final int fieldId;
  final int categoryId;
  final String name;
  final double price;
  final String image;
  final int harvest;
  final int stock;
  final String description;
  final int productSizeId;

  ProductUpdate({
    required this.productId,
    required this.fieldId,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.image,
    required this.harvest,
    required this.stock,
    required this.description,
    required this.productSizeId,
  });

  factory ProductUpdate.fromJson(Map<String, dynamic> json) {
    return ProductUpdate(
      productId: json['productId'] ?? 0,
      fieldId: json['fieldId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      harvest: json['harvest'] ?? 0,
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      productSizeId: json['productSizeId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'fieldId': fieldId,
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'image': image,
      'harvest': harvest,
      'stock': stock,
      'description': description,
      'productSizeId': productSizeId,
    };
  }
}
