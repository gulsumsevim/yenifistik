import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PanelimPage extends StatefulWidget {
  @override
  _PanelimPageState createState() => _PanelimPageState();
}

class _PanelimPageState extends State<PanelimPage> {
  List<dynamic> _fields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFields();
  }

  Future<void> _fetchFields() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Advisor/GetNotApprovalFieldForAdvisor'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/plain',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _fields = responseData['fieldNotApprovals'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Araziler yüklenemedi: ${response.statusCode}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveField(int fieldId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Advisor/ApprovalFieldStatus'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/plain',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': fieldId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arazi başarıyla onaylandı.')),
      );
      setState(() {
        _fetchFields();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arazi onaylanamadı: ${response.statusCode}')),
      );
    }
  }

  void _rejectField(int fieldId) {
    // Ret işlemleri burada yapılacak
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danışman Talepleri'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _fields.isEmpty
              ? Center(child: Text('Hiç arazi bulunamadı.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _fields.length,
                          itemBuilder: (context, index) {
                            final field = _fields[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            field['farmerName'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(field['fieldName']),
                                          SizedBox(height: 5),
                                          Text(field['address']),
                                          SizedBox(height: 5),
                                          Text(field['email']),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.check, color: Colors.green),
                                      onPressed: () => _approveField(field['id']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _rejectField(field['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PanelimPage(),
  ));
}
