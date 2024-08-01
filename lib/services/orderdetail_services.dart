import 'dart:convert';

import 'package:fistikpazar/models/orderdetail_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:http/http.dart' as http;

class OrderDetailService {
  static const String apiUrl = "https://api.fistikpazar.com/api/Customer/GetOrderProductWithId";

  Future<OrderDetail> getOrderDetail(int orderId) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(<String, int>{'orderId': orderId}),
      );

      print('HTTP yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return OrderDetail.fromJson(jsonData);
      } else {
        print(response.body);
        throw Exception('HTTP isteği başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Sipariş detayları yüklenemedi: $e');
    }
  }
}
