class Product {
  final int fieldId;
  final int categoryId;
  final String name;
  final double price;
  final String image;
  final int harvest;
  final int stock;
  final bool status;
  final String description;
  final int productSizeId;

  Product({
    required this.fieldId,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.image,
    required this.harvest,
    required this.stock,
    required this.status,
    required this.description,
    required this.productSizeId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      fieldId: json['fieldId'],
      categoryId: json['categoryId'],
      name: json['name'],
      price: json['price'],
      image: json['image'],
      harvest: json['harvest'],
      stock: json['stock'],
      status: json['status'],
      description: json['description'],
      productSizeId: json['productSizeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'image': image,
      'harvest': harvest,
      'stock': stock,
      'status': status,
      'description': description,
      'productSizeId': productSizeId,
    };
  }
}
