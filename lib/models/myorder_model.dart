class OrderProduct {
  final int orderProductId;
  final int productId;
  final String pictureUrl;
  final String productName;
  final double price;
  final int amount;
  final int orderStatus;

  OrderProduct({
    required this.orderProductId,
    required this.productId,
    required this.pictureUrl,
    required this.productName,
    required this.price,
    required this.amount,
    required this.orderStatus,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      orderProductId: json['orderProductId'],
      productId: json['productId'],
      pictureUrl: json['pictureUrl'],
      productName: json['productName'],
      price: (json['price'] as num).toDouble(),
      amount: json['amount'],
      orderStatus: json['orderStatus'],
    );
  }
}

class Order {
  final int orderId;
  final int userId;
  final String province;
  final String township;
  final String fullAddress;
  final String email;
  final String fullName;
  final String orderNote;
  final int orderStatus;
  final double totalPrice;
  final String invoice;
  final DateTime createdDate;
  final List<OrderProduct> orderProducts;

  Order({
    required this.orderId,
    required this.userId,
    required this.province,
    required this.township,
    required this.fullAddress,
    required this.email,
    required this.fullName,
    required this.orderNote,
    required this.orderStatus,
    required this.totalPrice,
    required this.invoice,
    required this.createdDate,
    required this.orderProducts,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      userId: json['userId'],
      province: json['province'],
      township: json['township'],
      fullAddress: json['fullAddress'],
      email: json['email'],
      fullName: json['fullName'],
      orderNote: json['orderNote'],
      orderStatus: json['orderStatus'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      invoice: json['invoice'],
      createdDate: DateTime.parse(json['createdDate']),
      orderProducts: (json['orderProducts'] as List)
          .map((i) => OrderProduct.fromJson(i))
          .toList(),
    );
  }

  Order copyWith({
    int? orderId,
    int? userId,
    String? province,
    String? township,
    String? fullAddress,
    String? email,
    String? fullName,
    String? orderNote,
    int? orderStatus,
    double? totalPrice,
    String? invoice,
    DateTime? createdDate,
    List<OrderProduct>? orderProducts,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      province: province ?? this.province,
      township: township ?? this.township,
      fullAddress: fullAddress ?? this.fullAddress,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      orderNote: orderNote ?? this.orderNote,
      orderStatus: orderStatus ?? this.orderStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      invoice: invoice ?? this.invoice,
      createdDate: createdDate ?? this.createdDate,
      orderProducts: orderProducts ?? this.orderProducts,
    );
  }
}