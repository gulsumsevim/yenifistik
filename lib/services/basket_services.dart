import 'dart:convert';
import 'package:fistikpazar/models/basket_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:http/http.dart' as http;

class BasketService {
  static const String getBasketProductsUrl = "https://api.fistikpazar.com/api/Customer/GetProductsInCart";
  static const String addProductToBasketUrl = "https://api.fistikpazar.com/api/Customer/AddProductToBasket";
  static const String removeProductFromBasketUrl = "https://api.fistikpazar.com/api/Customer/DeleteProductFromBasket";
  static const String updateBasketQuantityUrl = "https://api.fistikpazar.com/api/Customer/UpdateNumberOfProduct";

  Future<List<Baskets>> getAllBaskets() async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.get(
        Uri.parse(getBasketProductsUrl),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      print('HTTP yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)["baskets"];
        if (jsonData != null) {
          List<Baskets> baskets = jsonData.map<Baskets>((item) => Baskets.fromJson(item)).toList();
          return baskets;
        } else {
          throw Exception('Ürünler bulunamadı veya yanıtta hata var.');
        }
      } else {
        print(response.body);
        throw Exception('HTTP isteği başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ürünler yüklenemedi: $e');
    }
  }

  Future<void> addToBasket(int productId) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.post(
        Uri.parse(addProductToBasketUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(<String, int>{'productId': productId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Sepete ekleme işlemi başarısız oldu');
      }
    } catch (e) {
      throw Exception('Ürün sepete eklenirken bir hata oluştu: $e');
    }
  }

  Future<void> removeFromBasket(int basketId) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.post(
        Uri.parse(removeProductFromBasketUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(<String, int>{'basketId': basketId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Sepetten çıkarma işlemi başarısız oldu');
      }
    } catch (e) {
      throw Exception('Ürün sepetten çıkarılırken bir hata oluştu: $e');
    }
  }

  Future<void> updateBasketQuantity(int basketId, int newQuantity) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.put(
        Uri.parse(updateBasketQuantityUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(<String, int>{'basketId': basketId, 'numberOfProduct': newQuantity}),
      );

      if (response.statusCode != 200) {
        throw Exception('Miktar güncelleme işlemi başarısız oldu');
      }
    } catch (e) {
      throw Exception('Ürün miktarı güncellenirken bir hata oluştu: $e');
    }
  }
}
