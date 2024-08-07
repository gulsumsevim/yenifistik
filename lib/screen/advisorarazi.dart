import 'dart:convert';
import 'package:fistikpazar/screen/arazidetay.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArazilerimPage extends StatefulWidget {
  @override
  _ArazilerimPageState createState() => _ArazilerimPageState();
}

class _ArazilerimPageState extends State<ArazilerimPage> {
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
      Uri.parse('https://api.fistikpazar.com/api/Advisor/GetApprovalFieldForAdvisor'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/plain',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _fields = responseData['fieldInfoForAdvisors'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arazilerim'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _fields.isEmpty
              ? Center(child: Text('Henüz bir alan eklememişsiniz.'))
              : ListView.builder(
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(field['fieldName']),
                        subtitle: Text(field['address']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AraziDetayPage(field: field),
                            ),
                          ).then((value) {
                            if (value == true) {
                              setState(() {
                                _fetchFields();
                              });
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
