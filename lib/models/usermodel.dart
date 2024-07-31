class User {
  final int id;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final int roleId;
  final String? profileImage;
  final DateTime createdDate;
  final String description;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.roleId,
    this.profileImage,
    required this.createdDate,
    required this.description,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      phone: json['phone'],
      email: json['email'],
      roleId: json['roleId'],
      profileImage: json['profileImage'],
      createdDate: DateTime.parse(json['createdDate']),
      description: json['description'],
    );
  }
}
