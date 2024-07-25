class Orders {
  String? code;
  String? message;
  List<String>? errors;
  List<OrderIds>? orderIds;

  Orders({this.code, this.message, this.errors, this.orderIds});

  Orders.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    errors = json['errors'].cast<String>();
    if (json['orderIds'] != null) {
      orderIds = <OrderIds>[];
      json['orderIds'].forEach((v) {
        orderIds!.add(new OrderIds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    data['errors'] = this.errors;
    if (this.orderIds != null) {
      data['orderIds'] = this.orderIds!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderIds {
  int? orderId;
  String? createdDate;
  int? orderStatus;

  OrderIds({this.orderId, this.createdDate, this.orderStatus});

  OrderIds.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    createdDate = json['createdDate'];
    orderStatus = json['orderStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['createdDate'] = this.createdDate;
    data['orderStatus'] = this.orderStatus;
    return data;
  }
}