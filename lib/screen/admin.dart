import 'dart:convert';
import 'package:fistikpazar/models/usermodel.dart';
import 'package:fistikpazar/screen/admindetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<User>> futureUsers;
  String searchKeyword = "";
  int filterRoleId = 0; // 0 = Tüm Kullanıcılar, 1 = Müşteriler, 2 = Üreticiler, 3 = Danışmanlar, 4 = Adminler

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final response = await http.post(
      Uri.parse('https://api.fistikpazar.com/api/Admin/GetAllUserForAdmin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "pageNumber": 1,
        "pageSize": 1000, // Büyük bir değer
        "search": searchKeyword,
        "filterRoleId": filterRoleId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body)['users'];
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _filterUsers() {
    setState(() {
      futureUsers = fetchUsers();
    });
  }

  String _getRoleName(int roleId) {
    switch (roleId) {
      case 1:
        return 'Müşteri';
      case 2:
        return 'Üretici';
      case 3:
        return 'Danışman';
      case 4:
        return 'Admin';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Paneli'),
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: filterRoleId,
                    items: [
                      DropdownMenuItem(value: 0, child: Text('Tüm Kullanıcılar')),
                      DropdownMenuItem(value: 1, child: Text('Müşteriler')),
                      DropdownMenuItem(value: 2, child: Text('Üreticiler')),
                      DropdownMenuItem(value: 3, child: Text('Danışmanlar')),
                      DropdownMenuItem(value: 4, child: Text('Adminler')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        filterRoleId = value!;
                      });
                      _filterUsers();
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchKeyword = value;
                      });
                      _filterUsers();
                    },
                    decoration: InputDecoration(
                      labelText: 'Ara...',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Kullanıcı bulunamadı'));
                  } else {
                    List<User> users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        User user = users[index];
                        return Card(
                          child: ListTile(
                            leading: user.profileImage != null
                                ? CircleAvatar(backgroundImage: NetworkImage(user.profileImage!))
                                : CircleAvatar(child: Icon(Icons.person)),
                            title: Text('${user.name} ${user.surname}'),
                            subtitle: Text('Rol: ${_getRoleName(user.roleId)}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailScreen(userId: user.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
