import 'dart:convert';
import 'package:fistikpazar/models/begeni_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DailyLikeService {
  static const String baseUrl = 'https://api.fistikpazar.com/api';
  static const String dailyLikesUrl = '$baseUrl/Farmer/DailyLikes';

  static Future<List<DailyLike>> getDailyLikes() async {
    final String? token = await _getToken();
    if (token == null) {
      print('Token alınamadı');
      throw Exception('Token alınamadı');
    } else {
      print('Token alındı: $token');
    }

    final response = await http.get(
      Uri.parse(dailyLikesUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Veri başarıyla çekildi');
      List jsonResponse = jsonDecode(response.body)['dailyLikes'];
      return jsonResponse.map((data) => DailyLike.fromJson(data)).toList();
    } else {
      print('Günlük beğeni sayıları yüklenemedi! Hata kodu: ${response.statusCode}');
      throw Exception('Günlük beğeni sayıları yüklenemedi! Hata kodu: ${response.statusCode}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
