import 'dart:convert';
import 'package:fistikpazar/models/myorder_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String baseUrl = 'http://fruitmanagement.softsense.com.tr/api';
  static const String getOrdersUrl = '$baseUrl/Farmer/GetOrderProductForFarmer';

  Future<List<Order>> getOrders() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.get(
      Uri.parse(getOrdersUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['orderModels'] != null) {
        return (jsonData['orderModels'] as List)
            .map((i) => Order.fromJson(i))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Siparişler getirilemedi! Hata kodu: ${response.statusCode}');
    }
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
