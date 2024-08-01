import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  UserDetailScreen({required this.userId});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late Future<Map<String, dynamic>> futureUserDetail;

  @override
  void initState() {
    super.initState();
    futureUserDetail = fetchUserDetail(widget.userId);
  }

  Future<Map<String, dynamic>> fetchUserDetail(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('https://api.fistikpazar.com/api/Admin/GetUserById'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"id": userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user detail');
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
            'Kullanıcı Detayı',
            style: TextStyle(
              fontFamily: 'Yellowtail-Regular.ttf',
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureUserDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Kullanıcı detayları bulunamadı.'));
          } else {
            final userDetail = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                buildUserProfile(userDetail),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildUserProfile(Map<String, dynamic> userDetail) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      color: Color.fromARGB(255, 255, 240, 219),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            userDetail['profileImage'] != null && userDetail['profileImage'] != ''
                ? Image.network(userDetail['profileImage'], fit: BoxFit.cover, width: 150, height: 150)
                : Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey,
                    child: Center(child: Icon(Icons.image, size: 50)),
                  ),
            SizedBox(height: 20),
            buildDetailRow(Icons.person, 'Kullanıcı adı:', '${userDetail['name']} ${userDetail['surname']}'),
            buildDetailRow(Icons.email, 'E-posta:', userDetail['email'] ?? ''),
            buildDetailRow(Icons.phone, 'Telefon:', userDetail['phone'] ?? ''),
            buildDetailRow(Icons.info, 'Hakkında:', userDetail['description'] ?? 'Hakkında bilgi bulunmamaktadır.'),
            buildDetailRow(Icons.date_range, 'Kayıt Tarihi:', DateFormat.yMMM().format(DateTime.parse(userDetail['createdDate']))),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
