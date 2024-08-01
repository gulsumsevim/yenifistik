import 'dart:convert';
import 'package:fistikpazar/models/order_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String apiUrl = "https://api.fistikpazar.com/api/Customer/GetOrderId";
  static const String cancelOrderUrl = "https://api.fistikpazar.com/api/Customer/MoveProductsFromTempBasketToBasket";

  Future<Orders> getAllOrders() async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $_token',
        },
      );

      print('HTTP yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Orders.fromJson(jsonData);
      } else {
        print(response.body);
        throw Exception('HTTP isteği başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ürünler yüklenemedi: $e');
    }
  }

  Future<void> cancelOrder() async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.post(
        Uri.parse(cancelOrderUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'accept': 'text/plain',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Sipariş iptal edilemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
      }
    } catch (e) {
      throw Exception('Sipariş iptal edilemedi: $e');
    }
  }
}
