import 'dart:convert';
import 'package:fistikpazar/models/advisor_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdvisorService {
  static const String baseUrl = 'http://fruitmanagement.softsense.com.tr/api/Farmer';

  static Future<List<Advisor>> getAdvisors() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/GetAllAdvisor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "pageNumber": 0,
        "pageSize": 20,
        "search": "",
      }),
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      if (jsonData['code'] == "400") {
        throw Exception('Yetkisiz erişim! Lütfen tekrar giriş yapın.');
      }
      if (jsonData == null || !jsonData.containsKey('advisors') || jsonData['advisors'] == null) {
        throw Exception('Geçersiz veri formatı');
      }

      List<dynamic> advisorsJson = jsonData['advisors'];
      List<Advisor> advisors = advisorsJson.map((item) => Advisor.fromJson(item)).toList();

      return advisors;
    } else {
      throw Exception('Danışmanlar yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> addFieldToAdvisor(int fieldId, int advisorId) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/AddFieldToAdvisor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "fieldId": fieldId,
        "advisorId": advisorId
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Arazi danışmana atanamadı! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }
}
