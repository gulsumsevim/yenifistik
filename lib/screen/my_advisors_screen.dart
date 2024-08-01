import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fistikpazar/models/lands_model.dart';

class FieldService {
  static const String baseUrl = 'https://api.fistikpazar.com/api';
  static const String getFieldInfoUrl = '$baseUrl/Farmer/GetField';
  static const String getApprovalFieldInfoUrl = '$baseUrl/Farmer/GetApprovalFieldInfoForFarmer';
  static const String updateFieldInfoUrl = '$baseUrl/Farmer/UpdateFieldInfo';
  static const String deleteFieldUrl = '$baseUrl/Farmer/DeleteField';
  static const String getAdvisorWithIdUrl = '$baseUrl/Farmer/GetAdvisorWithId';

  static Future<List<FieldInfo>> getFields() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.get(
      Uri.parse(getFieldInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<FieldInfo> fields = [];

      if (jsonData.containsKey('fields')) {
        var fieldsJson = jsonData['fields'];

        for (var item in fieldsJson) {
          fields.add(FieldInfo.fromJson(item));
        }
      } else {
        print('fields key not found in JSON response.');
      }

      return fields;
    } else {
      throw Exception('Araziler yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<List<ApprovalFieldInfo>> getApprovalFields() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.get(
      Uri.parse(getApprovalFieldInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<ApprovalFieldInfo> approvalFields = [];

      if (jsonData.containsKey('approvalInfos')) {
        var approvalFieldsJson = jsonData['approvalInfos'];

        for (var item in approvalFieldsJson) {
          approvalFields.add(ApprovalFieldInfo.fromJson(item));
        }
      } else {
        print('approvalInfos key not found in JSON response.');
      }

      return approvalFields;
    } else {
      throw Exception('Onaylı tarlalar yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<AdvisorInfo> getAdvisorWithId(int advisorId) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(getAdvisorWithIdUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'advisorId': advisorId}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return AdvisorInfo.fromJson(jsonData);
    } else {
      throw Exception('Danışman bilgisi yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> updateField(FieldInfo field) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.put(
      Uri.parse(updateFieldInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(field.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Güncelleme başarısız oldu! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> deleteField(int fieldId) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.delete(
      Uri.parse(deleteFieldUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fieldId': fieldId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Silme işlemi başarısız oldu! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

class ApprovalFieldInfo {
  final int id;
  final int fieldId;
  final String fieldName;
  final int advisorId;
  final bool advisorApproval;
  final String description;
  final DateTime createdDate;

  ApprovalFieldInfo({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.advisorId,
    required this.advisorApproval,
    required this.description,
    required this.createdDate,
  });

  factory ApprovalFieldInfo.fromJson(Map<String, dynamic> json) {
    return ApprovalFieldInfo(
      id: json['id'],
      fieldId: json['fieldId'],
      fieldName: json['fieldName'],
      advisorId: json['advisorId'],
      advisorApproval: json['advisorApproval'],
      description: json['description'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'fieldName': fieldName,
      'advisorId': advisorId,
      'advisorApproval': advisorApproval,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

class AdvisorInfo {
  final String picture;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String about;

  AdvisorInfo({
    required this.picture,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.about,
  });

  factory AdvisorInfo.fromJson(Map<String, dynamic> json) {
    return AdvisorInfo(
      picture: json['picture'],
      name: json['name'],
      surname: json['surname'],
      phone: json['phone'],
      email: json['email'],
      about: json['about'],
    );
  }
}

class MyAdvisorsScreen extends StatefulWidget {
  @override
  _MyAdvisorsScreenState createState() => _MyAdvisorsScreenState();
}

class _MyAdvisorsScreenState extends State<MyAdvisorsScreen> {
  List<ApprovalFieldInfo> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    try {
      List<ApprovalFieldInfo> fieldInfos = await FieldService.getApprovalFields();
      setState(() {
        fields = fieldInfos;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading fields: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> pastelColors = [
      Color(0xFFFFF8E1), // Light Yellow
      Color(0xFFFFEBEE), // Light Red
      Color(0xFFE8F5E9), // Light Green
      Color(0xFFE3F2FD), // Light Blue
      Color(0xFFFCE4EC), // Light Pink
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text('Danışmanlarım'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : fields.isEmpty
              ? Center(
                  child: Text(
                    'Hiçbir danışman bulunamadı',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FieldDetailScreen(advisorId: field.advisorId),
                          ),
                        );
                      },
                      child: Card(
                        color: pastelColors[index % pastelColors.length], // Use pastel colors
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.fieldName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Adres: ${field.fieldName}'),
                              Text('Alan: ${field.fieldId} m²'),
                              Text('Ağaç Sayısı: ${field.advisorId}'),
                              Text('Lokasyon: ${field.description}'),
                              SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                               
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class FieldDetailScreen extends StatefulWidget {
  final int advisorId;

  FieldDetailScreen({required this.advisorId});

  @override
  _FieldDetailScreenState createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  late Future<AdvisorInfo> advisorInfo;

  @override
  void initState() {
    super.initState();
    advisorInfo = FieldService.getAdvisorWithId(widget.advisorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danışman Detayları'),
      ),
      body: FutureBuilder<AdvisorInfo>(
        future: advisorInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final advisor = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  advisor.picture.isNotEmpty
                      ? Center(
                          child: Image.network(advisor.picture, height: 150, width: 150),
                        )
                      : Container(),
                  SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      title: Text('Ad: ${advisor.name} ${advisor.surname}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Telefon: ${advisor.phone}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Email: ${advisor.email}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Hakkında: ${advisor.about}'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Veri bulunamadı'));
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyAdvisorsScreen(),
  ));
}
