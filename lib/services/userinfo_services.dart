import 'dart:convert';
import 'package:fistikpazar/models/user%C4%B1nfo_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String userInfoUrl = 'https://api.fistikpazar.com/api/Auth/UserInfo';
  static const String updateUserInfoUrl = 'https://api.fistikpazar.com/api/Auth/UpdateUserInfo';

  Future<UserInfo?> getUserInfo(String token) async {
    final response = await http.get(
      Uri.parse(userInfoUrl),
      headers: {
        'accept': 'text/plain',
        'Authorization': 'Bearer $token', // Token'ı burada gönderiyoruz
      },
    );

    print('Request URL: $userInfoUrl');
    print('Token: $token');

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to load user info. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load user info');
    }
  }

  Future<bool> updateUserInfo(UserInfo userInfo, String token) async {
    final response = await http.post(
      Uri.parse(updateUserInfoUrl),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Token'ı burada gönderiyoruz
      },
      body: jsonEncode({
        'name': userInfo.name,
        'surname': userInfo.surname,
        'email': userInfo.email,
        'phone': userInfo.phone,
      }),
    );

    print('Request URL: $updateUserInfoUrl');
    print('Token: $token');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update user info. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }
}
