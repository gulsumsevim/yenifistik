
class Addresses {
  int? adressId;
  String? province;
  String? township;
  String? fullAddress;
   int? provinceId;
  int? townshipId;
    bool isEditing = false; // Düzenleme durumunu takip eden alan


  Addresses({this.adressId, this.province, this.township, this.fullAddress, required int provinceId, required int townshipId});

  Addresses.fromJson(Map<String, dynamic> json) {
    adressId = json['adressId'];
    province = json['province'];
    township = json['township'];
     provinceId = json['provinceId'];
    townshipId = json['townshipId'];
    fullAddress = json['fullAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adressId'] = this.adressId;
    data['province'] = this.province;
    data['township'] = this.township;
    data['provinceId'] = this.provinceId;
    data['townshipId'] = this.townshipId;
    data['fullAddress'] = this.fullAddress;
    return data;
  }
}