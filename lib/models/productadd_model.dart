class MyAddProduct {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String image;
  final String field;
  final int harvest;
  final int stock;
  final DateTime createdDate;
  final int productSize;
  final int numberOfLike;
  final bool isLiked;

  MyAddProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.image,
    required this.field,
    required this.harvest,
    required this.stock,
    required this.createdDate,
    required this.productSize,
    required this.numberOfLike,
    required this.isLiked,
  });

  factory MyAddProduct.fromJson(Map<String, dynamic> json) {
    return MyAddProduct(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      description: json['description'],
      image: json['image'],
      field: json['field'],
      harvest: json['harvest'],
      stock: json['stock'],
      createdDate: DateTime.parse(json['createdDate']),
      productSize: json['productSize'],
      numberOfLike: json['numberOfLike'],
      isLiked: json['isLiked'],
    );
  }
}
