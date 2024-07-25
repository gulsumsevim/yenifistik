import 'package:fistikpazar/models/user%C4%B1nfo_model.dart';
import 'package:fistikpazar/screen/profileedit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fistikpazar/services/userinfo_services.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<UserInfo?> userInfoFuture;
  final UserService userService = UserService();
  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchUserInfo();
  }

  Future<void> _loadTokenAndFetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token != null) {
      setState(() {
        userInfoFuture = userService.getUserInfo(token!);
      });
    } else {
      print('Token is null');
    }
  }

  void _navigateToEditProfile(UserInfo userInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              EditProfilePage(userInfo: userInfo, token: token!)),
    ).then((value) {
      if (value != null && value == true) {
        setState(() {
          userInfoFuture = userService.getUserInfo(token!);
        });
      }
    });
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
            'Profilim',
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
      body: token == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<UserInfo?>(
              future: userInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  UserInfo? userInfo = snapshot.data;
                  return userInfo != null
                      ? SingleChildScrollView(
                          child: _buildUserInfo(userInfo),
                        )
                      : Center(child: Text('Kullanıcı bilgisi bulunamadı'));
                } else {
                  return Center(child: Text('Bilinmeyen bir hata oluştu'));
                }
              },
            ),
    );
  }

  Widget _buildUserInfo(UserInfo userInfo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                userInfo.picture != null && userInfo.picture!.isNotEmpty
                    ? NetworkImage(userInfo.picture!)
                    : AssetImage('assets/default_profile.png')
                        as ImageProvider, // Default profil resmi
          ),
          SizedBox(height: 16),
          _buildProfileField(Icons.person, 'Ad', userInfo.name),
          SizedBox(height: 16),
          _buildProfileField(Icons.person, 'Soyad', userInfo.surname),
          SizedBox(height: 16),
          _buildProfileField(Icons.phone, 'Telefon', userInfo.phone),
          SizedBox(height: 16),
          _buildProfileField(Icons.email, 'E-Posta', userInfo.email),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _navigateToEditProfile(userInfo);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 255, 240, 219)), // Arka plan rengi
              foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.black), // Metin rengi
              padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12)), // İç kenar boşlukları
              textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18)), // Metin stili
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Yuvarlak köşeler
                ),
              ),
            ),
            child: Text('Profili Düzenle'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String? value) {
    return Card(
      color: const Color.fromARGB(255, 255, 240, 219),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(label),
        subtitle: Text(value ?? ''),
        trailing:
            Icon(Icons.arrow_forward_ios, color: Colors.grey[700], size: 16),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserProfilePage(),
  ));
}
