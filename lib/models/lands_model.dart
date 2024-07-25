class FieldInfo {
  int userId;
  int fieldId;
  String name;
  String address;
  int area;  // double yerine int
  int numberOfTree;
  String location;
  String createdDate;

  FieldInfo({
    required this.userId,
    required this.fieldId,
    required this.name,
    required this.address,
    required this.area,
    required this.numberOfTree,
    required this.location,
    required this.createdDate,
  });

  factory FieldInfo.fromJson(Map<String, dynamic> json) {
    return FieldInfo(
      userId: json['userId'],
      fieldId: json['fieldId'],
      name: json['name'],
      address: json['address'],
      area: (json['area'] is double) ? (json['area'] as double).toInt() : json['area'],
      numberOfTree: (json['numberOfTree'] is double) ? (json['numberOfTree'] as double).toInt() : json['numberOfTree'],
      location: json['location'],
      createdDate: json['createdDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fieldId': fieldId,
      'name': name,
      'address': address,
      'area': area,
      'numberOfTree': numberOfTree,
      'location': location,
      'createdDate': createdDate,
    };
  }
}
