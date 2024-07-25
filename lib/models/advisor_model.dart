class Advisor {
  final int userId;
  final String profileImage;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final int numberOfAdvisorApproval;
  final String advisorDescription;

  Advisor({
    required this.userId,
    required this.profileImage,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.numberOfAdvisorApproval,
    required this.advisorDescription,
  });

  factory Advisor.fromJson(Map<String, dynamic> json) {
    return Advisor(
      userId: json['userId'],
      profileImage: json['profilImage'],
      name: json['name'],
      surname: json['surname'],
      phone: json['phone'],
      email: json['email'],
      numberOfAdvisorApproval: json['numberOfAdvisorApproval'],
      advisorDescription: json['advisorDescription'],
    );
  }
}
