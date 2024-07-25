import 'package:flutter/material.dart';
import 'package:fistikpazar/services/register_services.dart';
import 'package:fistikpazar/screen/home.dart';
import 'package:fistikpazar/screen/login_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignupPage(),
  ));
}

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late FocusNode _surnameFocusNode;
  late FocusNode _phoneFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _surnameFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _surnameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool success = await RegisterService().register(
          _nameController.text,
          _surnameController.text,
          _phoneController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (success) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Başarılı"),
                content: Text(
                    "Kayıt işlemi başarıyla gerçekleştirildi. E-posta adresinize bir doğrulama linki gönderildi. Lütfen e-postanızı kontrol edin ve hesabınızı doğrulayın."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text("Tamam"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0, // Arka plan resminin üstte başlaması için
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/yenii.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          "*HESAP OLUŞTUR*",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Lato', // Font ailesi belirtildi
                            fontSize: 25, // Boyut küçültüldü
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildNameTextField(),
                        const SizedBox(height: 15),
                        _buildSurnameTextField(),
                        const SizedBox(height: 15),
                        _buildPhoneTextField(),
                        const SizedBox(height: 15),
                        _buildEmailTextField(),
                        const SizedBox(height: 15),
                        _buildPasswordField(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _register,
                          child: Text(
                            "Kaydol",
                            style: TextStyle(fontSize: 18, color: Colors.white), // Boyut küçültüldü
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(vertical: 14), // Yükseklik azaltıldı
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameTextField() {
    return TextFormField(
      style: TextStyle(fontSize: 14, color: Colors.white), // Boyut küçültüldü
      controller: _nameController,
      decoration: InputDecoration(
        hintText: "Adı",
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        prefixIcon: Icon(Icons.person),
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
      textInputAction: TextInputAction.next,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(_surnameFocusNode),
    );
  }

  Widget _buildSurnameTextField() {
    return TextFormField(
      style: TextStyle(fontSize: 14, color: Colors.white), // Boyut küçültüldü
      controller: _surnameController,
      focusNode: _surnameFocusNode,
      decoration: InputDecoration(
        hintText: "Soyadı",
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        prefixIcon: Icon(Icons.person),
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
      textInputAction: TextInputAction.next,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(_phoneFocusNode),
    );
  }

  Widget _buildPhoneTextField() {
    return TextFormField(
      controller: _phoneController,
      style: TextStyle(fontSize: 14, color: Colors.white), // Boyut küçültüldü
      focusNode: _phoneFocusNode,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: "Telefon",
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        prefixIcon: Icon(Icons.phone_android),
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
      textInputAction: TextInputAction.next,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(_emailFocusNode),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      style: TextStyle(fontSize: 14, color: Colors.white), // Boyut küçültüldü
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "E-mail",
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
      textInputAction: TextInputAction.next,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(_passwordFocusNode),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      style: TextStyle(fontSize: 14, color: Colors.white), // Boyut küçültüldü
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        hintText: "Şifre",
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        prefixIcon: Icon(Icons.password),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
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
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
    );
  }
}
