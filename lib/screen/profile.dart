import 'package:fistikpazar/models/colors.dart';
import 'package:fistikpazar/screen/adress.dart';
import 'package:fistikpazar/screen/cardpage.dart';
import 'package:fistikpazar/screen/commentpage.dart';
import 'package:fistikpazar/screen/login_page.dart';
import 'package:fistikpazar/screen/order.dart';
import 'package:fistikpazar/screen/password_change.dart';
import 'package:fistikpazar/screen/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ProfilePage());
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileName = 'Yükleniyor...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
            'Profil',
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _buildListTile(Icons.person, 'Bilgilerim', context),
                  _buildListTile(Icons.home_filled, 'Adreslerim', context),
                  _buildListTile(
                    Icons.shopping_bag,
                    'Siparişlerim',
                    context,
                  ),
                  _buildListTile(Icons.payment, 'Kartlarım', context),
                  _buildListTile(Icons.payment, 'Yorumlarım', context),
                  _buildListTile(
                    Icons.password,
                    'Şifre değiştir',
                    context,
                  ),
                  _buildListTile(
                    Icons.logout,
                    'Çıkış Yap',
                    context,
                    _logout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildListTile(IconData icon, String title, BuildContext context,
      [VoidCallback? onTap]) {
    return Card(
      color: const Color.fromARGB(255, 255, 240, 219),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap ??
            () {
              if (title == 'Bilgilerim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              } else if (title == 'Adreslerim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddressScreen()),
                );
              } else if (title == 'Siparişlerim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderListScreen()),
                );
              } else if (title == 'Kartlarım') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CardListPage()),
                );}
                else if (title == 'Yorumlarım') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommentListScreen()),
                );
              } else if (title == 'Şifre değiştir') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordChangePage()),
                );
              }
            },
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
      ),
    );
  }
}
