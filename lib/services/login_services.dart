import 'dart:convert';
import 'package:fistikpazar/models/login_model.dart';
import 'package:fistikpazar/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://fruitmanagement.softsense.com.tr/api";

  Future<Login> loginUser(String email, String password, bool rememberMe) async {
    final String loginUrl = "$baseUrl/Auth/Login";

    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'isRemember': rememberMe,
    };

    final response = await http.post(
      Uri.parse(loginUrl),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    print(response.body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['code'] == "200") {
        await saveToken(jsonResponse['token']);
        await saveRoleId(jsonResponse['roleId']); // Rol bilgisini kaydetme
        if (jsonResponse['guid'] != null) {
          await saveGuid(jsonResponse['guid']);
        }
        return Login.fromJson(jsonResponse);
      } else {
        throw Exception(jsonResponse['message']);
      }
    } else {
      throw Exception('Giriş Yapılamadı!');
    }
  }

  static const String _tokenKey = 'token';
  static const String _guidKey = 'guid';
  static const String _roleIdKey = 'roleId';

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getGuid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guidKey);
  }

  static Future<void> saveGuid(String guid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guidKey, guid);
  }

  static Future<int?> getRoleId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleIdKey);
  }

  static Future<void> saveRoleId(int roleId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_roleIdKey, roleId);
  }

  Future<Orders>? fetchOrders(String token) {}
}
