class User {
  String? name;
  String? surname;
  String? phone;
  String? email;

  User({this.name, this.surname, this.phone, this.email});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    surname = json['surname'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}
