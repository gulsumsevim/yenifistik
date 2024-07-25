class AdressAdd {
  String? code;
  String? message;
  List<String>? errors;
  List<Provinces>? provinces;

  AdressAdd({this.code, this.message, this.errors, this.provinces});

  AdressAdd.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    errors = json['errors'].cast<String>();
    if (json['provinces'] != null) {
      provinces = <Provinces>[];
      json['provinces'].forEach((v) {
        provinces!.add(new Provinces.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    data['errors'] = this.errors;
    if (this.provinces != null) {
      data['provinces'] = this.provinces!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Provinces {
  int? provinceId;
  String? provinceName;

  Provinces({this.provinceId, this.provinceName});

  Provinces.fromJson(Map<String, dynamic> json) {
    provinceId = json['provinceId'];
    provinceName = json['provinceName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['provinceId'] = this.provinceId;
    data['provinceName'] = this.provinceName;
    return data;
  }
}