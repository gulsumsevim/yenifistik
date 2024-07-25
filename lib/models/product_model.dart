class Products {
  int? productId;
  String? field;
  String? category;
  String? name;
  double? price; 
  String? image;
  int? harvest;
  int? stock;
  String? description;
  String? createdDate;
  int? productSize;
  int? numberOfLike;
  bool? isLiked;

  Products(
      {this.productId,
      this.field,
      this.category,
      this.name,
      this.price,
      this.image,
      this.harvest,
      this.stock,
      this.description,
      this.createdDate,
      this.productSize,
      this.numberOfLike,
      this.isLiked});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    field = json['field'];
    category = json['category'];
    name = json['name'];
    price = json['price']?.toDouble(); 
    image = json['image'];
    harvest = json['harvest'];
    stock = json['stock'];
    description = json['description'];
    createdDate = json['createdDate'];
    productSize = json['productSize'];
    numberOfLike = json['numberOfLike'];
    isLiked = json['isLiked'];
  }

  

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['field'] = this.field;
    data['category'] = this.category;
    data['name'] = this.name;
    data['price'] = this.price;
    data['image'] = this.image;
    data['harvest'] = this.harvest;
    data['stock'] = this.stock;
    data['description'] = this.description;
    data['createdDate'] = this.createdDate;
    data['productSize'] = this.productSize;
    data['numberOfLike'] = this.numberOfLike;
    data['isLiked'] = this.isLiked;
    return data;
  }
}