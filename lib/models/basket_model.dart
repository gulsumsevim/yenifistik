class Baskets {
  final int basketId;
  final int productId;
  int numberOfProduct; // Final yerine var olabilir
  final String name;
  final double price;
  final String image;
  final int harvest;
  final int stock;
  final String description;
  final int productSize;

  Baskets({
    required this.basketId,
    required this.productId,
    required this.numberOfProduct,
    required this.name,
    required this.price,
    required this.image,
    required this.harvest,
    required this.stock,
    required this.description,
    required this.productSize,
  });

  factory Baskets.fromJson(Map<String, dynamic> json) {
    return Baskets(
      basketId: json['basketId'],
      productId: json['productId'],
      numberOfProduct: json['numberOfProduct'],
      name: json['name'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      productSize: json['productSize'] != null ? int.parse(json['productSize'].toString()) : 0,
      image: json['image'],
      harvest: json['harvest'],
      stock: json['stock'],
      description: json['description'],
    );
  }

  void updateQuantity(int newQuantity) {
    numberOfProduct = newQuantity;
  }
}
