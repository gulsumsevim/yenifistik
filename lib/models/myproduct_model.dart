class MyProduct {
  final int productId;
  final int fieldId;
  final int categoryId;
  final bool status;
  final int productSizeId;
  final String field;
  final String category;
  final String name;
  final double price;
  final String image;
  final int harvest;
  final int stock;
  final String description;
  final DateTime createdDate;
  final int productSize;
  final int numberOfLike;
  final bool isLiked;

  MyProduct({
    required this.productId,
    required this.fieldId,
    required this.categoryId,
    required this.status,
    required this.productSizeId,
    required this.field,
    required this.category,
    required this.name,
    required this.price,
    required this.image,
    required this.harvest,
    required this.stock,
    required this.description,
    required this.createdDate,
    required this.productSize,
    required this.numberOfLike,
    required this.isLiked,
  });

  factory MyProduct.fromJson(Map<String, dynamic> json) {
    return MyProduct(
      productId: json['productId'] ?? 0,
      fieldId: json['fieldId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      status: json['status'] ?? false,
      productSizeId: json['productSizeId'] ?? 0,
      field: json['field'] ?? '',
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      harvest: json['harvest'] ?? 0,
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      createdDate: DateTime.parse(json['createdDate'] ?? DateTime.now().toString()),
      productSize: json['productSize'] ?? 0,
      numberOfLike: json['numberOfLike'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'fieldId': fieldId,
      'categoryId': categoryId,
      'status': status,
      'productSizeId': productSizeId,
      'field': field,
      'category': category,
      'name': name,
      'price': price,
      'image': image,
      'harvest': harvest,
      'stock': stock,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
      'productSize': productSize,
      'numberOfLike': numberOfLike,
      'isLiked': isLiked,
    };
  }

  MyProduct copyWith({
    int? productId,
    int? fieldId,
    int? categoryId,
    bool? status,
    int? productSizeId,
    String? field,
    String? category,
    String? name,
    double? price,
    String? image,
    int? harvest,
    int? stock,
    String? description,
    DateTime? createdDate,
    int? productSize,
    int? numberOfLike,
    bool? isLiked,
  }) {
    return MyProduct(
      productId: productId ?? this.productId,
      fieldId: fieldId ?? this.fieldId,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      productSizeId: productSizeId ?? this.productSizeId,
      field: field ?? this.field,
      category: category ?? this.category,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      harvest: harvest ?? this.harvest,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      productSize: productSize ?? this.productSize,
      numberOfLike: numberOfLike ?? this.numberOfLike,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
