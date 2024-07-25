class UserInfo {
  String? code;
  String? message;
  List<String>? errors;
  int? userId;
  String? name;
  String? surname;
  String? phone;
  String? email;
  String? picture;

  UserInfo({
    this.code,
    this.message,
    this.errors,
    this.userId,
    this.name,
    this.surname,
    this.phone,
    this.email,
    this.picture,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    errors = json['errors']?.cast<String>();
    userId = json['userId']; // JSON'dan userId okunuyor
    name = json['name'];
    surname = json['surname'];
    phone = json['phone'];
    email = json['email'];
    picture = json['picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    data['errors'] = this.errors;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['picture'] = this.picture;
    return data;
  }
}
