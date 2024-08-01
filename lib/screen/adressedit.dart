import 'package:flutter/material.dart';
import 'package:fistikpazar/models/adress_model.dart';
import 'package:fistikpazar/services/adress_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditAddressScreen extends StatefulWidget {
  final Addresses address;

  EditAddressScreen({required this.address});

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _provinceId;
  late int _townshipId;
  late String _fullAddress;
  List<dynamic> _provinces = [];
  List<dynamic> _townships = [];
  String? _selectedProvince;
  String? _selectedTownship;

  @override
  void initState() {
    super.initState();
    _provinceId = widget.address.provinceId ?? 0;  // Varsayılan değer
    _townshipId = widget.address.townshipId ?? 0;  // Varsayılan değer
    _fullAddress = widget.address.fullAddress ?? ''; // Varsayılan değer
    _fetchProvinces();
    if (_provinceId != 0) {
      _fetchTownships(_provinceId);
    }
  }

  Future<void> _fetchProvinces() async {
    final response = await http.get(
      Uri.parse('https://api.fistikpazar.com/api/Address/SehirleriListele'),
      headers: {
        'accept': 'text/plain',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _provinces = data['provinces'];
        _selectedProvince = _provinces.firstWhere(
          (province) => province['provinceId'] == _provinceId,
          orElse: () => null,
        )?['provinceName'];
      });
    } else {
      // Hata yönetimi
      print('Şehirler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<void> _fetchTownships(int provinceId) async {
    final response = await http.post(
      Uri.parse('https://api.fistikpazar.com/api/Address/IlceleriListele'),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: json.encode({'provinceId': provinceId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _townships = data['townships'];
        _selectedTownship = _townships.firstWhere(
          (township) => township['townshipId'] == _townshipId,
          orElse: () => null,
        )?['townshipName'];
      });
    } else {
      // Hata yönetimi
      print('İlçeler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await AddressService().updateAddress(widget.address.adressId!, _provinceId, _townshipId, _fullAddress);
        Navigator.pop(context, true); // Başarılı güncellemeden sonra geri dön
      } catch (e) {
        print('Adres güncellenemedi: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adres güncellenirken bir hata oluştu')),
        );
      }
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
            'Adres Düzenle',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDropdownField(
                  'İl',
                  _selectedProvince,
                  _provinces.map<DropdownMenuItem<String>>((province) {
                    return DropdownMenuItem<String>(
                      value: province['provinceName'],
                      child: Text(province['provinceName']),
                    );
                  }).toList(),
                  (String? newValue) {
                    setState(() {
                      _selectedProvince = newValue;
                      _selectedTownship = null;
                      _townships = [];
                    });
                    int provinceId = _provinces.firstWhere((province) => province['provinceName'] == newValue)['provinceId'];
                    _provinceId = provinceId;
                    _fetchTownships(provinceId);
                  },
                ),
                SizedBox(height: 20),
                _buildDropdownField(
                  'İlçe',
                  _selectedTownship,
                  _townships.map<DropdownMenuItem<String>>((township) {
                    return DropdownMenuItem<String>(
                      value: township['townshipName'],
                      child: Text(township['townshipName']),
                    );
                  }).toList(),
                  (String? newValue) {
                    setState(() {
                      _selectedTownship = newValue;
                    });
                    int townshipId = _townships.firstWhere((township) => township['townshipName'] == newValue)['townshipId'];
                    _townshipId = townshipId;
                  },
                ),
                SizedBox(height: 20),
                _buildAddressField(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateAddress,
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
                  child: Text('KAYDET'),
                ),
              ],
            ),
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
          initialValue: _fullAddress,
          decoration: InputDecoration(labelText: 'Adres', border: InputBorder.none),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen adres girin';
            }
            return null;
          },
          onSaved: (value) {
            _fullAddress = value!;
          },
        ),
      ),
    );
  }
}
