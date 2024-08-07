import 'dart:convert';
import 'package:fistikpazar/models/productdetail_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:http/http.dart' as http;
import 'package:fistikpazar/models/product_model.dart';

class ProductService {
  static const String baseUrl = 'https://api.fistikpazar.com/api';
  static const String getAllProductUrl = '$baseUrl/Customer/GetAllProduct';
  static const String getProductByIdUrl = '$baseUrl/Customer/GetProductById';
  static const String addProductToBasketUrl = '$baseUrl/Customer/AddProductToBasket';
  static const String addLikeToProductUrl = '$baseUrl/Customer/AddLikeToProduct';
  static const String removeLikeFromProductUrl = '$baseUrl/Customer/RemoveLikeTheProduct';
  static const String addCommentToProductUrl = '$baseUrl/Customer/AddCommentToProduct';
  static const String isProductFavoriteUrl = '$baseUrl/Customer/IsProductFavorite';
  static const String getLikedProductsUrl = '$baseUrl/Customer/GetMyLikedProduct'; // Eklenen URL

  static Future<List<Products>> getAllProducts() async {
    Map<String, dynamic> requestBody = {
      "pageNumber": 1,
      "pageSize": 20,
      "search": "",
      "filterOptionId": 0,
      "categoryIds": [],
      "productSizeId": null,
      "minPrice": null,
      "maxPrice": null
    };

    var response = await http.post(
      Uri.parse(getAllProductUrl),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<Products> productList = [];

      if (jsonData.containsKey('products')) {
        var productsJson = jsonData['products'];

        for (var item in productsJson) {
          productList.add(Products.fromJson(item));
        }
      }

      return productList;
    } else {
      throw Exception('Ürünler yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<Details> getProductById(int productId) async {
    var response = await http.post(
      Uri.parse(getProductByIdUrl),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"productId": productId}),
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return Details.fromJson(jsonData);
    } else {
      throw Exception('Ürün getirilemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> addProductToBasket(int productId) async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(addProductToBasketUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Sepete ekleme işlemi başarısız oldu. Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> addLikeToProduct(int productId) async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(addLikeToProductUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ürünü beğenme işlemi başarısız oldu. Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> removeLikeFromProduct(int productId) async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(removeLikeFromProductUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'numberOfLikeTableId': productId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ürünü beğenmeden çıkarma işlemi başarısız oldu. Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<bool> isProductFavorite(int productId) async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(isProductFavoriteUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
      }),
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData['isFavorite'];
    } else {
      throw Exception('Ürünün favori durumu kontrol edilemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> addCommentToProduct(int productId, String comment, int point) async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(addCommentToProductUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
        'comment': comment,
        'point': point,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Yorum ekleme işlemi başarısız oldu. Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }
  static Future<List<int>> getLikedProducts() async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.get(
      Uri.parse(getLikedProductsUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['products'] != null) {
        return (jsonData['products'] as List).map((item) => item['productId'] as int).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Favori ürünler yüklenemedi. Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

}
