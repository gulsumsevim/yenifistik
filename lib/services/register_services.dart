import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  final String registerUrl = 'https://api.fistikpazar.com/api/Auth/Register';

  Future<bool> register(String name, String surname, String phone, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
        },
        body: json.encode({
          'name': name,
          'surname': surname,
          'phone': phone,
          'email': email,
          'password': password, // Ensure to send the password field as well
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(responseBody['message'] ?? 'Kayıt işlemi başarısız oldu!');
      }
    } catch (e) {
      throw Exception('Kayıt işlemi başarısız oldu: $e');
    }
  }
}
