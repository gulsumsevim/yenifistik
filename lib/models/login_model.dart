class Login {
  String? code;
  String? message;
  List<String>? errors;
  String? guid;
  int? userId;
  String? token;
  String? name;
  String? email;
  String? surname;
  String? phone;
  int? roleId;

  Login(
      {this.code,
      this.message,
      this.errors,
      this.guid,
      this.userId,
      this.token,
      this.name,
      this.email,
      this.surname,
      this.phone,
      this.roleId});

  Login.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    errors = json['errors'].cast<String>();
    guid = json['guid'];
    userId = json['userId'];
    token = json['token'];
    name = json['name'];
    email = json['email'];
    surname = json['surname'];
    phone = json['phone'];
    roleId = json['roleId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    data['errors'] = this.errors;
    data['guid'] = this.guid;
    data['userId'] = this.userId;
    data['token'] = this.token;
    data['name'] = this.name;
    data['email'] = this.email;
    data['surname'] = this.surname;
    data['phone'] = this.phone;
    data['roleId'] = this.roleId;
    return data;
  }
}