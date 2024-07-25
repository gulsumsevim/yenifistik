class ProductDetailModel {
  final int productId;
  final String name;
  final String category;
  final double price;
  final String image;
  final String description;
  final int harvest;
  final int stock;
  final List<CommentModel> comments;
  final List<CampaignModel> campaigns;

  ProductDetailModel({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
    required this.harvest,
    required this.stock,
    required this.comments,
    required this.campaigns,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      productId: json['productId'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      image: json['image'],
      description: json['description'],
      harvest: json['harvest'],
      stock: json['stock'],
      comments: (json['comments'] as List).map((e) => CommentModel.fromJson(e)).toList(),
      campaigns: (json['campaigns'] as List).map((e) => CampaignModel.fromJson(e)).toList(),
    );
  }
}

class CommentModel {
  final int commentId;
  final int productId;
  final String productName;
  final String comment;
  final int customerId;
  final String customerName;
  final int point;
  final DateTime createdDate;

  CommentModel({
    required this.commentId,
    required this.productId,
    required this.productName,
    required this.comment,
    required this.customerId,
    required this.customerName,
    required this.point,
    required this.createdDate,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'],
      productId: json['productId'],
      productName: json['productName'],
      comment: json['commentt'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      point: json['point'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}

class CampaignModel {
  final int campaignId;
  final String name;
  final int productId;
  final int quantity;
  final double discountRate;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdDate;

  CampaignModel({
    required this.campaignId,
    required this.name,
    required this.productId,
    required this.quantity,
    required this.discountRate,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdDate,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      campaignId: json['campaignId'],
      name: json['name'],
      productId: json['productId'],
      quantity: json['quantity'],
      discountRate: json['discountRate'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
