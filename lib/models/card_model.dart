class CrediCard {
  String? code;
  String? message;
  List<String>? errors;
  List<Cards>? cards;

  CrediCard({this.code, this.message, this.errors, this.cards});

  CrediCard.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    errors = json['errors'] != null ? List<String>.from(json['errors']) : null;
    if (json['cards'] != null) {
      cards = <Cards>[];
      json['cards'].forEach((v) {
        cards!.add(Cards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.errors != null) {
      data['errors'] = this.errors;
    }
    if (this.cards != null) {
      data['cards'] = this.cards!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cards {
  int? cardId;
  String? cardNumber;
  String? expirationDate;
  String? securityCode;
  String? name;
  String? surname;

  Cards({this.cardId, this.cardNumber, this.expirationDate, this.securityCode, this.name, this.surname});

  Cards.fromJson(Map<String, dynamic> json) {
    cardId = json['cardId'];
    cardNumber = json['cardNumber'];
    expirationDate = json['expirationDate'];
    securityCode = json['securityCode'];
    name = json['name'];
    surname = json['surname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cardId'] = this.cardId;
    data['cardNumber'] = this.cardNumber;
    data['expirationDate'] = this.expirationDate;
    data['securityCode'] = this.securityCode;
    data['name'] = this.name;
    data['surname'] = this.surname;
    return data;
  }
}
