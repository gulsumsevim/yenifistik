import 'package:fistikpazar/services/card_services.dart';
import 'package:flutter/material.dart';
import 'package:fistikpazar/models/card_model.dart';

class EditCardPage extends StatefulWidget {
  final Cards card;

  EditCardPage({required this.card});

  @override
  _EditCardPageState createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cardNumberController;
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;
  late TextEditingController _cvcController;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController(text: widget.card.cardNumber);
    _nameController = TextEditingController(text: widget.card.name);
    _surnameController = TextEditingController(text: widget.card.surname);
    if (widget.card.expirationDate != null && widget.card.expirationDate!.contains('/')) {
      var dateParts = widget.card.expirationDate!.split('/');
      _monthController = TextEditingController(text: dateParts[0]);
      _yearController = TextEditingController(text: dateParts[1]);
    } else {
      _monthController = TextEditingController();
      _yearController = TextEditingController();
    }
    _cvcController = TextEditingController(text: widget.card.securityCode);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final card = Cards(
        cardId: widget.card.cardId,
        cardNumber: _cardNumberController.text,
        expirationDate: '${_monthController.text}/${_yearController.text}',
        securityCode: _cvcController.text,
        name: _nameController.text,
        surname: _surnameController.text,
      );

      try {
        await CardService().updateCard(card);
        Navigator.pop(context, card); // Sayfayı kapat ve güncellenmiş kart bilgilerini gönder
      } catch (e) {
        print('Kart güncelleme başarısız: $e');
      }
    }
  }

  void _cancel() {
    Navigator.pop(context); // Sayfayı kapat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kart Düzenle'),
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
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Adınız',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _surnameController,
                      decoration: InputDecoration(
                        labelText: 'Soyadınız',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Kart Numarası',
                  labelStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
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
                      controller: _monthController,
                      decoration: InputDecoration(
                        labelText: 'Ay',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
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
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'Yıl',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
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
                      controller: _cvcController,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
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
                      onPressed: _saveCard,
                      icon: Icon(Icons.check),
                      label: Text('Kaydet'),
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
                      onPressed: _cancel,
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
