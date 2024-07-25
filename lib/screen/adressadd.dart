import 'package:fistikpazar/services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String? selectedProvince;
  String? selectedTownship;
  String? fullAddress;

  List<dynamic> provinces = [];
  List<dynamic> townships = [];

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Address/SehirleriListele'),
      headers: {
        'accept': 'text/plain',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        provinces = data['provinces'];
      });
    } else {
      // Hata yönetimi
      print('İl verileri yüklenemedi: ${response.statusCode}');
    }
  }

  Future<void> fetchTownships(int provinceId) async {
    final response = await http.post(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Address/IlceleriListele'),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: json.encode({'provinceId': provinceId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        townships = data['townships'];
      });
    } else {
      // Hata yönetimi
      print('İlçe verileri yüklenemedi: ${response.statusCode}');
    }
  }

  Future<void> addAddress() async {
    final String? token = await ApiService.getToken(); // Token alınması
    if (token == null) {
      print('Token alınamadı');
      return;
    }

    int provinceId = provinces.firstWhere((province) => province['provinceName'] == selectedProvince)['provinceId'];
    int townshipId = townships.firstWhere((township) => township['townshipName'] == selectedTownship)['townshipId'];

    final response = await http.post(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Address/AddAdressInfo'),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Authorization başlığı eklendi
      },
      body: json.encode({
        'provinceId': provinceId,
        'townshipId': townshipId,
        'fullAdress': fullAddress,
      }),
    );

    if (response.statusCode == 200) {
      // Başarılı kayıt
      print('Adres başarıyla eklendi');
      Navigator.pop(context, true); // Adresin başarıyla eklendiğini belirtmek için true döndür
    } else {
      // Hata yönetimi
      print('Adres eklenirken hata oluştu: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adres eklenirken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Yeni Adres Ekle',
            style: TextStyle(
              fontFamily: 'Yellowtail-Regular.ttf', // Kullanmak istediğiniz font ailesi
              fontSize: 25.0, // Yazı boyutu
              fontWeight: FontWeight.bold, // Yazı kalınlığı
              color: Colors.black, // Yazı rengi
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDropdownField(
                'İl',
                selectedProvince,
                provinces.map<DropdownMenuItem<String>>((province) {
                  return DropdownMenuItem<String>(
                    value: province['provinceName'],
                    child: Text(province['provinceName']),
                  );
                }).toList(),
                (String? newValue) {
                  setState(() {
                    selectedProvince = newValue;
                    selectedTownship = null; // İl değiştiğinde ilçe seçimlerini sıfırla
                    townships = [];
                  });
                  int provinceId = provinces.firstWhere((province) => province['provinceName'] == newValue)['provinceId'];
                  fetchTownships(provinceId);
                },
              ),
              SizedBox(height: 20),
              _buildDropdownField(
                'İlçe',
                selectedTownship,
                townships.map<DropdownMenuItem<String>>((township) {
                  return DropdownMenuItem<String>(
                    value: township['townshipName'],
                    child: Text(township['townshipName']),
                  );
                }).toList(),
                (String? newValue) {
                  setState(() {
                    selectedTownship = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              _buildAddressField(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  addAddress();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 101, 212, 73)), // Arka plan rengi
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // Metin rengi
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16, vertical: 12)), // İç kenar boşlukları
                  textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 18)), // Metin stili
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Yuvarlak köşeler
                    ),
                  ),
                ),
                child: Text('Adresi Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    void Function(String?)? onChanged,
  ) {
    return Card(
      color: Color.fromARGB(255, 255, 240, 219),
      child: ListTile(
        leading: Icon(Icons.location_city),
        title: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(labelText: label, border: InputBorder.none),
          items: items,
          onChanged: onChanged,
          validator: (value) => value == null ? 'Lütfen $label seçin' : null,
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return Card(
      color: Color.fromARGB(255, 255, 240, 219),
      child: ListTile(
        leading: Icon(Icons.home),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Tam Adres', border: InputBorder.none),
          onChanged: (value) {
            setState(() {
              fullAddress = value;
            });
          },
        ),
      ),
    );
  }
}
