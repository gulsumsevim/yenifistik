import 'dart:convert';
import 'package:fistikpazar/models/comment_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommentService {
  static const String baseUrl = 'https://api.fistikpazar.com/api';
  static const String getCommentsUrl = '$baseUrl/Farmer/GetAllAdvisorComment';

  static Future<List<Comment>> getAllComments() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.get(
      Uri.parse(getCommentsUrl),
      headers: {
        'accept': 'text/plain',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<Comment> comments = [];
      if (jsonResponse.containsKey('comments')) {
        for (var comment in jsonResponse['comments']) {
          comments.add(Comment.fromJson(comment));
        }
      }
      return comments;
    } else {
      throw Exception('Yorumlar yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
