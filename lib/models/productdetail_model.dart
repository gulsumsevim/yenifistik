class Details {
  String? code;
  String? message;
  List<String>? errors;
  int? fieldId;
  String? field;
  int? categoryId;
  String? category;
  String? name;
  double? price;
  String? image;
  List<AdditionalImage>? additionalImages;
  int? harvest;
  int? stock;
  String? description;
  String? createdDate;
  int? productSize;
  String? fName;
  String? surname;
  String? email;
  String? phone;
  int? numberOfLike;
  bool? isLiked;
  List<Comments>? comments;
  List<String>? campaigns;

  Details({
    this.code,
    this.message,
    this.errors,
    this.fieldId,
    this.field,
    this.categoryId,
    this.category,
    this.name,
    this.price,
    this.image,
    this.additionalImages,
    this.harvest,
    this.stock,
    this.description,
    this.createdDate,
    this.productSize,
    this.fName,
    this.surname,
    this.email,
    this.phone,
    this.numberOfLike,
    this.isLiked,
    this.comments,
    this.campaigns,
  });

  Details.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    errors = json['errors'] != null ? json['errors'].cast<String>() : [];
    fieldId = json['fieldId'];
    field = json['field'];
    categoryId = json['categoryId'];
    category = json['category'];
    name = json['name'];
    price = (json['price'] as num?)?.toDouble();
    image = json['image'];
    if (json['additionalImages'] != null) {
      additionalImages = <AdditionalImage>[];
      json['additionalImages'].forEach((v) {
        additionalImages!.add(AdditionalImage.fromJson(v));
      });
    }
    harvest = json['harvest'];
    stock = json['stock'];
    description = json['description'];
    createdDate = json['createdDate'];
    productSize = json['productSize'];
    fName = json['fName'];
    surname = json['surname'];
    email = json['email'];
    phone = json['phone'];
    numberOfLike = json['numberOfLike'];
    isLiked = json['isLiked'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(Comments.fromJson(v));
      });
    }
    campaigns = json['campaigns'] != null ? json['campaigns'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    data['errors'] = this.errors;
    data['fieldId'] = this.fieldId;
    data['field'] = this.field;
    data['categoryId'] = this.categoryId;
    data['category'] = this.category;
    data['name'] = this.name;
    data['price'] = this.price;
    data['image'] = this.image;
    if (this.additionalImages != null) {
      data['additionalImages'] =
          this.additionalImages!.map((v) => v.toJson()).toList();
    }
    data['harvest'] = this.harvest;
    data['stock'] = this.stock;
    data['description'] = this.description;
    data['createdDate'] = this.createdDate;
    data['productSize'] = this.productSize;
    data['fName'] = this.fName;
    data['surname'] = this.surname;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['numberOfLike'] = this.numberOfLike;
    data['isLiked'] = this.isLiked;
    if (this.comments != null) {
      data['comments'] = this.comments!.map((v) => v.toJson()).toList();
    }
    data['campaigns'] = this.campaigns;
    return data;
  }
}

class AdditionalImage {
  int? id;
  String? url;

  AdditionalImage({this.id, this.url});

  AdditionalImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}

class Comments {
  int? commentId;
  int? productId;
  String? productName;
  String? commentt;
  int? customerId;
  String? customerName;
  double? point;
  String? createdDate;

  Comments({
    this.commentId,
    this.productId,
    this.productName,
    this.commentt,
    this.customerId,
    this.customerName,
    this.point,
    this.createdDate,
  });

  Comments.fromJson(Map<String, dynamic> json) {
    commentId = json['commentId'];
    productId = json['productId'];
    productName = json['productName'];
    commentt = json['commentt'];
    customerId = json['customerId'];
    customerName = json['customerName'];
    point = (json['point'] as num?)?.toDouble();
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['commentId'] = this.commentId;
    data['productId'] = this.productId;
    data['productName'] = this.productName;
    data['commentt'] = this.commentt;
    data['customerId'] = this.customerId;
    data['customerName'] = this.customerName;
    data['point'] = this.point;
    data['createdDate'] = this.createdDate;
    return data;
  }
}
