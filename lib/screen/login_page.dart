import 'package:fistikpazar/models/login_model.dart';
import 'package:fistikpazar/screen/home.dart';
import 'package:fistikpazar/screen/signup_page.dart';
import 'package:fistikpazar/screen/reset_password_page.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPageContent(),
    );
  }
}

class LoginPageContent extends StatefulWidget {
  @override
  _LoginPageContentState createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<LoginPageContent> {
  bool _rememberMe = false;
  bool _obscureText = true;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleRememberMe(bool? newValue) {
    if (newValue != null) {
      setState(() {
        _rememberMe = newValue;
      });
    }
  }

  void loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if (username != null && password != null) {
      setState(() {
        _usernameController.text = username;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  void saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      prefs.setString('username', _usernameController.text);
      prefs.setString('password', _passwordController.text);
    } else {
      prefs.remove('username');
      prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/arkaplann.png"),
                fit: BoxFit.fill,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _header(context),
                _inputField(context, _usernameController, _passwordController),
                _forgotPassword(context),
                _signup(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(context) {
    return const Column(
      children: [
        SizedBox(height: 120),
        Text(
          "FISTIKPAZAR",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Baslik",
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Doğadan Soframıza...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "altyazi",
          ),
        ),
      ],
    );
  }

  Widget _inputField(context, TextEditingController usernameController,
      TextEditingController passwordController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        TextFormField(
          style: TextStyle(fontSize: 16, color: Colors.white),
          controller: usernameController,
          decoration: InputDecoration(
              hintText: "Kullanıcı Adı",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Color(0xff000000).withOpacity(0.9),
              hintStyle: TextStyle(color: Colors.grey.shade700),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: (_) {
            FocusScope.of(context).nextFocus();
          },
          onEditingComplete: () {
            FocusScope.of(context).nextFocus();
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          style: TextStyle(fontSize: 16, color: Colors.white),
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Şifre",
            hintStyle: TextStyle(color: Colors.grey.shade700),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Color(0xff000000).withOpacity(0.9),
            filled: true,
            prefixIcon: const Icon(Icons.password),
            suffixIcon: IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          obscureText: _obscureText,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            String username = usernameController.text;
            String password = passwordController.text;

            try {
              Login loginResponse =
                  await ApiService().loginUser(username, password, _rememberMe);

              await ApiService.saveToken(loginResponse.token!);
              if (loginResponse.guid != null) {
                await ApiService.saveGuid(loginResponse.guid!);
              }
              saveCredentials();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => CustomerHomePage()),
                (Route<dynamic> route) => false,
              );
            } catch (e) {
              print("Hata: $e");
              if (e.toString() ==
                  'Exception: Böyle bir kullanıcı bulunamadı.') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kullanıcı adı veya şifre yanlış!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (e.toString() == 'Exception: Şifre yanlış') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Şifre yanlış!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              child: const Text(
                "GİRİŞ YAP",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _forgotPassword(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: _toggleRememberMe,
            ),
            const Text(
              "Beni Hatırla",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                );
              },
              child: const Text(
                "Şifreni mi unuttun?",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Hesap oluşturun!",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignupPage()));
          },
          child: const Text(
            "Kayıt Ol",
            style: TextStyle(
                color: Colors.orange,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
