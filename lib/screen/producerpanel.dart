import 'package:fistikpazar/screen/advisor.dart';
import 'package:fistikpazar/screen/digitalcons.dart';
import 'package:fistikpazar/screen/login_page.dart';
import 'package:fistikpazar/screen/mylands.dart';
import 'package:fistikpazar/screen/myorder.dart';
import 'package:fistikpazar/screen/myproduct.dart';
import 'package:fistikpazar/screen/mystatictics.dart';
import 'package:fistikpazar/screen/panel_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _checkUserRole(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data == true) {
            return PanelPage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }

  Future<bool> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    int? roleId = prefs.getInt('roleId');
    return roleId == 2;
  }
}

class PanelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PanelScreen(),
    );
  }
}

class PanelScreen extends StatefulWidget {
  @override
  _PanelScreenState createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  String profileName = 'Yükleniyor...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    // Burada profil verilerini yükleyebilirsiniz

    setState(() {
      _isLoading = false;
    });
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
            'Panelim',
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
                   _buildListTile(CupertinoIcons.rectangle_grid_2x2, 'Panelim', context),
                  _buildListTile(Icons.person, 'Arazilerim', context),
                  _buildListTile(Icons.home_filled, 'Ürünlerim', context),
                  _buildListTile(
                    Icons.shopping_bag,
                    'Siparişlerim',
                    context,
                  ),
                  _buildListTile(Icons.payment, 'İstatistiklerim', context),
                  _buildListTile(
                    Icons.password,
                    'Danışman',
                    context,
                  ),
                  _buildListTile(
                    Icons.smart_toy,
                    'Dijital Danışman',
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
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap ??
            () {
              if (title == 'Panelim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PanelimScreen()),
                );
              } else if (title == 'Arazilerim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandsScreen()),
                );
              }  else if (title == 'Ürünlerim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductScreen()),
                );
              } else if (title == 'Siparişlerim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyOrderScreen()),
                );
              } else if (title == 'İstatistiklerim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatisticsScreen()),
                );
              } else if (title == 'Danışman') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdvisorScreen()),
                );
              } else if (title == 'Dijital Danışman') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DigitalAdvisorScreen()),
                );
              }
            },
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
      ),
    );
  }
}

