import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirmationPage extends StatefulWidget {
  final double totalPrice;
  final int totalItems;
  final String orderNote;

  OrderConfirmationPage({
    required this.totalPrice,
    required this.totalItems,
    required this.orderNote,
  });

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _isBillingSameAsShipping = true;
  List<dynamic> _provinces = [];
  List<dynamic> _townships = [];
  String? _selectedProvince;
  String? _selectedTownship;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    final response = await http.get(
      Uri.parse('https://api.fistikpazar.com/api/Address/SehirleriListele'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _provinces = responseData['provinces'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şehirler yüklenemedi')));
    }
  }

  Future<void> _fetchTownships(int provinceId) async {
    final response = await http.post(
      Uri.parse('https://api.fistikpazar.com/api/Address/IlceleriListele'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'provinceId': provinceId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _townships = responseData['townships'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İlçeler yüklenemedi')));
    }
  }

  Future<void> _submitOrder() async {
    // Alanların boş olup olmadığını kontrol et
    if (_selectedProvince == null || _selectedTownship == null || _addressController.text.isEmpty ||
        _nameController.text.isEmpty || _surnameController.text.isEmpty || _cardNumberController.text.isEmpty ||
        _expiryMonthController.text.isEmpty || _expiryYearController.text.isEmpty || _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    final String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token alınamadı')));
      return;
    }

    final String fullName = "${_nameController.text} ${_surnameController.text}";
    final String expirationDate = "${_expiryMonthController.text}/${_expiryYearController.text}";

    final response = await http.post(
      Uri.parse('https://api.fistikpazar.com/api/Customer/AddOrder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'provinceId': int.tryParse(_selectedProvince ?? '0') ?? 0,
        'townshipId': int.tryParse(_selectedTownship ?? '0') ?? 0,
        'fullAddress': _addressController.text,
        'cardNumber': _cardNumberController.text,
        'expirationDate': expirationDate,
        'securityCode': _cvcController.text,
        'email': 'email@example.com', // Kullanıcının email adresi
        'fullName': fullName,
        'orderNote': widget.orderNote,
        'orderStatus': 0, // Sipariş durumu burada belirtilecek
        'invoice': _isBillingSameAsShipping ? _addressController.text : _invoiceController.text,
      }),
    );

    print('HTTP yanıtı: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş başarıyla oluşturuldu')));
      Navigator.pop(context);
    } else {
      final responseData = jsonDecode(response.body);
      final message = responseData['message'] ?? 'Sipariş oluşturulamadı';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        elevation: 0,
        title: Text(
          'Sipariş Özeti',
          style: TextStyle(
            fontFamily: 'Yellowtail-Regular.ttf',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adres Bilgileri',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'İl',
                        border: OutlineInputBorder(),
                      ),
                      items: _provinces.map<DropdownMenuItem<String>>((province) {
                        return DropdownMenuItem<String>(
                          value: province['provinceId'].toString(),
                          child: Text(province['provinceName']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProvince = newValue;
                          _selectedTownship = null; // İlçe seçimini sıfırla
                          _townships = []; // İlçeleri sıfırla
                        });
                        _fetchTownships(int.parse(_selectedProvince!));
                      },
                      value: _selectedProvince,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'İlçe',
                        border: OutlineInputBorder(),
                      ),
                      items: _townships.map<DropdownMenuItem<String>>((township) {
                        return DropdownMenuItem<String>(
                          value: township['townshipId'].toString(),
                          child: Text(township['townshipName']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTownship = newValue;
                        });
                      },
                      value: _selectedTownship,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Tam Adres',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              CheckboxListTile(
                title: Text('Fatura adresi aynı olsun'),
                value: _isBillingSameAsShipping,
                onChanged: (bool? value) {
                  setState(() {
                    _isBillingSameAsShipping = value!;
                  });
                },
              ),
              if (!_isBillingSameAsShipping)
                TextField(
                  controller: _invoiceController,
                  decoration: InputDecoration(
                    labelText: 'Fatura Adresi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              SizedBox(height: 10),
              Text(
                'Kart Bilgileri',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Adınız',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _surnameController,
                      decoration: InputDecoration(
                        labelText: 'Soyadınız',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Kart Numarası',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryMonthController,
                      decoration: InputDecoration(
                        labelText: 'Ay',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _expiryYearController,
                      decoration: InputDecoration(
                        labelText: 'Yıl',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _cvcController,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Sipariş Özeti',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 240, 219),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ara toplam:'),
                        Text('${widget.totalPrice.toStringAsFixed(2)} ₺'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ek ücretler:'),
                        Text('0 ₺'),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toplam:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.totalPrice.toStringAsFixed(2)} ₺',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Sipariş Notu:'),
                    Text(widget.orderNote.isNotEmpty ? widget.orderNote : 'Not girilmedi.'),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Geri düğmesi
                          },
                          child: Text('Geri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _submitOrder,
                          child: Text('Oluştur'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
