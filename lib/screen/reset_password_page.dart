import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();

    Future<void> sendResetPasswordRequest(String email) async {
      final url = Uri.parse('http://fruitmanagement.softsense.com.tr/api/Auth/PasswordForgot');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({'email': email});

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Şifre yenileme bağlantısı e-posta adresinize gönderildi.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bir hata oluştu, lütfen tekrar deneyin.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu, lütfen internet bağlantınızı kontrol edin.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text('Şifre Yenileme'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/yeni.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Spacer(flex: 2), // Daha fazla boşluk ekleyin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        
                        const SizedBox(height: 20),
                        _buildEmailTextField(_emailController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            String email = _emailController.text;
                            sendResetPasswordRequest(email);
                          },
                          child: Text(
                            "Şifre Yenileme Bağlantısı Gönder",
                            style: TextStyle(fontSize: 13, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(300, 50), // Minimum boyutu ayarla
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(flex: 3), // Daha az boşluk ekleyin
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTextField(TextEditingController controller) {
    return TextFormField(
      style: TextStyle(fontSize: 14, color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: "E-posta Adresi",
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        prefixIcon: Icon(Icons.email),
        fillColor: Color(0xff000000).withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.orange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
    );
  }
}
