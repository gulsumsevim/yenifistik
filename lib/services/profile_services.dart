import 'dart:convert';

import 'package:http/http.dart' as http;


Future<bool> updateProfile(String name, String surname, String phone, String email) async {
  Map<String, dynamic> requestBody = {
    "name": name,
    "surname": surname,
    "phone": phone,
    "email": email,
  };

  var response = await http.post(
    Uri.parse('http://fruitmanagement.softsense.com.tr/api/Auth/UpdateUserInfo'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Profil güncellenemedi!');
  }
}
