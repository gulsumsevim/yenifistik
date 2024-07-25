import 'package:flutter/material.dart';
import 'package:fistikpazar/models/card_model.dart';
import 'package:fistikpazar/services/card_services.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _surname;
  String? _cardNumber;
  String? _month;
  String? _year;
  String? _cvc;

  final CardService _cardService = CardService();

  void _addCard() async {
    if (_formKey.currentState!.validate()) {
      final card = Cards(
        name: _name,
        surname: _surname,
        cardNumber: _cardNumber,
        expirationDate: '$_month/$_year',
        securityCode: _cvc,
      );

      try {
        await _cardService.addCard(card);
        Navigator.pop(context, true); // Kart eklendikten sonra geri dön ve true değeri gönder
      } catch (e) {
        print('Kart ekleme başarısız: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Kart ekleme başarısız: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kart Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Adınız',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        _name = value;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Soyadınız',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        _surname = value;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Kart Numarası',
                  labelStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _cardNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kart numarası gerekli';
                  }
                  if (value.length < 16 || value.length > 19) {
                    return 'Geçerli bir kart numarası giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ay',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _month = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ay gerekli';
                        }
                        int? month = int.tryParse(value);
                        if (month == null || month < 1 || month > 12) {
                          return 'Geçerli bir ay giriniz (1-12)';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Yıl',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _year = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Yıl gerekli';
                        }
                        int? year = int.tryParse(value);
                        if (year == null || year < 2024 || year > 2030) {
                          return 'Geçerli bir yıl giriniz (2024-2030)';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _cvc = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CVC gerekli';
                        }
                        if (value.length != 3) {
                          return 'Geçerli bir CVC giriniz (3 haneli)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addCard,
                      icon: Icon(Icons.check),
                      label: Text('Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shadowColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // İptal tuşuna basıldığında geri dön
                      },
                      icon: Icon(Icons.close),
                      label: Text('İptal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shadowColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
