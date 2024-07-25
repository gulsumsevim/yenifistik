class OrderDetail {
  String? code;
  String? message;
  List<String>? errors;
  int? orderId;
  String? province;
  String? township;
  String? fullAddress;
  String? cardNumber;
  String? expirationDate;
  String? securityCode;
  String? email;
  String? fullName;
  String? orderNote;
  int? orderStatus;
  num? totalPrice;  // num türü hem int hem de double için uygundur
  String? invoice;
  String? createdDate;
  List<OrderProduct>? orderProducts;

  OrderDetail({
    this.code,
    this.message,
    this.errors,
    this.orderId,
    this.province,
    this.township,
    this.fullAddress,
    this.cardNumber,
    this.expirationDate,
    this.securityCode,
    this.email,
    this.fullName,
    this.orderNote,
    this.orderStatus,
    this.totalPrice,
    this.invoice,
    this.createdDate,
    this.orderProducts,
  });

  OrderDetail.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    errors = json['errors'].cast<String>();
    orderId = json['orderId'];
    province = json['province'];
    township = json['township'];
    fullAddress = json['fullAddress'];
    cardNumber = json['cardNumber'];
    expirationDate = json['expirationDate'];
    securityCode = json['securityCode'];
    email = json['email'];
    fullName = json['fullName'];
    orderNote = json['orderNote'];
    orderStatus = json['orderStatus'];
    totalPrice = json['totalPrice'] is int ? (json['totalPrice'] as int).toDouble() : json['totalPrice'];
    invoice = json['invoice'];
    createdDate = json['createdDate'];
    if (json['orderProducts'] != null) {
      orderProducts = <OrderProduct>[];
      json['orderProducts'].forEach((v) {
        orderProducts!.add(OrderProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    data['errors'] = this.errors;
    data['orderId'] = this.orderId;
    data['province'] = this.province;
    data['township'] = this.township;
    data['fullAddress'] = this.fullAddress;
    data['cardNumber'] = this.cardNumber;
    data['expirationDate'] = this.expirationDate;
    data['securityCode'] = this.securityCode;
    data['email'] = this.email;
    data['fullName'] = this.fullName;
    data['orderNote'] = this.orderNote;
    data['orderStatus'] = this.orderStatus;
    data['totalPrice'] = this.totalPrice;
    data['invoice'] = this.invoice;
    data['createdDate'] = this.createdDate;
    if (this.orderProducts != null) {
      data['orderProducts'] = this.orderProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderProduct {
  int? orderId;
  int? userId;
  int? productId;
  String? pictureUrl;
  String? productName;
  num? price;  // num türü hem int hem de double için uygundur
  int? amount;
  int? orderStatus;

  OrderProduct({
    this.orderId,
    this.userId,
    this.productId,
    this.pictureUrl,
    this.productName,
    this.price,
    this.amount,
    this.orderStatus,
  });

  OrderProduct.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    userId = json['userId'];
    productId = json['productId'];
    pictureUrl = json['pictureUrl'];
    productName = json['productName'];
    price = json['price'] is int ? (json['price'] as int).toDouble() : json['price'];
    amount = json['amount'];
    orderStatus = json['orderStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['userId'] = this.userId;
    data['productId'] = this.productId;
    data['pictureUrl'] = this.pictureUrl;
    data['productName'] = this.productName;
    data['price'] = this.price;
    data['amount'] = this.amount;
    data['orderStatus'] = this.orderStatus;
    return data;
  }
}
