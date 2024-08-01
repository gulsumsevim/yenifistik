import 'dart:convert';
import 'dart:io';
import 'package:fistikpazar/models/user%C4%B1nfo_model.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fistikpazar/services/userinfo_services.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  final UserInfo userInfo;
  final String token;
  final Function(UserInfo) onUpdateUserInfo;

  EditProfilePage({required this.userInfo, required this.token, required this.onUpdateUserInfo});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  int? userId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userInfo.name);
    _surnameController = TextEditingController(text: widget.userInfo.surname);
    _emailController = TextEditingController(text: widget.userInfo.email);
    _phoneController = TextEditingController(text: widget.userInfo.phone);

    // Kullanıcı kimliğini widget.userInfo.userId'den alma
    userId = widget.userInfo.userId;
    print("Initial userId from userInfo: $userId");

    // Eğer userId hala null ise, token'dan çıkartmayı dene
    if (userId == null) {
      final decodedToken = _parseJwt(widget.token);
      if (decodedToken != null && decodedToken.containsKey('value')) {
        userId = int.tryParse(decodedToken['value']);
        print("UserId extracted from token: $userId");
      }
    }
  }

  Map<String, dynamic>? _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      final updatedUserInfo = UserInfo(
        name: _nameController.text,
        surname: _surnameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        picture: widget.userInfo.picture,
        userId: userId, // Kullanıcı ID'sini ekliyoruz
      );

      bool success = await _userService.updateUserInfo(updatedUserInfo, widget.token);

      if (success) {
        if (_image != null && userId != null) {
          await _uploadImage(_image!, widget.token, userId!);
          updatedUserInfo.picture = _image!.path; // Güncellenmiş resim yolunu ayarla
        }
        widget.onUpdateUserInfo(updatedUserInfo); // Kullanıcı bilgilerini güncelle
        Navigator.pop(context); // Sayfayı kapat
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bilgiler güncellenemedi')),
        );
      }
    }
  }

  Future<void> _uploadImage(File image, String token, int userId) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('https://api.fistikpazar.com/api/Auth/UploadImageToProfile?userId=$userId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(await http.MultipartFile.fromPath('formFile', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
      print('Response body: $responseData');
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
            'Profili Düzenle',
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : widget.userInfo.picture != null && widget.userInfo.picture!.isNotEmpty
                              ? NetworkImage(widget.userInfo.picture!)
                              : AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.grey),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildProfileField(Icons.person, 'Ad', _nameController),
                SizedBox(height: 16),
                _buildProfileField(Icons.person, 'Soyad', _surnameController),
                SizedBox(height: 16),
                _buildProfileField(Icons.email, 'E-Posta', _emailController),
                SizedBox(height: 16),
                _buildProfileField(Icons.phone, 'Telefon', _phoneController),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateUserInfo,
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

  Widget _buildProfileField(IconData icon, String label, TextEditingController controller) {
    return Card(
      color: Color.fromARGB(255, 255, 240, 219),
      child: ListTile(
        leading: Icon(icon),
        title: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label, border: InputBorder.none),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen $label girin';
            }
            return null;
          },
        ),
      ),
    );
  }
}
