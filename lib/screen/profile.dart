import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fistikpazar/screen/adress.dart';
import 'package:fistikpazar/screen/cardpage.dart';
import 'package:fistikpazar/screen/commentpage.dart';
import 'package:fistikpazar/screen/order.dart';
import 'package:fistikpazar/screen/password_change.dart';
import 'package:fistikpazar/screen/userinfo.dart';
import 'package:fistikpazar/screen/home.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
       title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Profilim',
            style: TextStyle(
              fontFamily: 'Yellowtail-Regular.ttf',
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildProfileButton(
            context,
            icon: Icons.person,
            label: 'Bilgilerim',
            destination: UserProfilePage(),
          ),
          _buildProfileButton(
            context,
            icon: Icons.home,
            label: 'Adreslerim',
            destination: AddressScreen(),
          ),
          _buildProfileButton(
            context,
            icon: Icons.shopping_bag,
            label: 'Siparişlerim',
            destination: OrderListScreen(),
          ),
        /*  _buildProfileButton(
            context,
            icon: Icons.credit_card,
            label: 'Kartlarım',
            destination: CardListPage(),
          ),*/
          _buildProfileButton(
            context,
            icon: Icons.comment,
            label: 'Yorumlarım',
            destination: CommentListScreen(),
          ),
          _buildProfileButton(
            context,
            icon: Icons.lock,
            label: 'Şifre değiştir',
            destination: PasswordChangePage(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Widget destination}) {
    return Card(
        color: const Color.fromARGB(255, 255, 240, 219),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(label),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => CustomerHomePage()),
      (Route<dynamic> route) => false,
    );
  }
}
