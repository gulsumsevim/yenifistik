import 'dart:convert';
import 'dart:io';
import 'package:fistikpazar/models/MyProductDetail.dart';
import 'package:fistikpazar/models/myproduct_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class MyProductService {
  static const String baseUrl = 'http://fruitmanagement.softsense.com.tr/api';
  static const String getMyAllProductUrl = '$baseUrl/Farmer/GetMyAllProduct';
  static const String addProductUrl = '$baseUrl/Farmer/AddProduct';
  static const String getProductDetailUrl = '$baseUrl/Farmer/GetProductById';
  static const String deleteProductUrl = '$baseUrl/Farmer/DeleteProduct';
  static const String updateProductInfoUrl = '$baseUrl/Farmer/UpdateProductInfo';

  static Future<List<MyProduct>> getMyProducts() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.get(
      Uri.parse(getMyAllProductUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<MyProduct> products = [];

      if (jsonData.containsKey('products')) {
        var productsJson = jsonData['products'];

        for (var item in productsJson) {
          products.add(MyProduct.fromJson(item));
        }
      } else {
        print('products key not found in JSON response.');
      }

      return products;
    } else {
      throw Exception('Ürünler yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<ProductUpdate> getProductDetail(int productId) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(getProductDetailUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return ProductUpdate.fromJson(jsonData);
    } else {
      print('Failed to load product detail: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load product detail: ${response.statusCode}, ${response.body}');
    }
  }

  static Future<void> deleteProduct(int productId) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.put(
      Uri.parse(deleteProductUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Ürün silinemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> updateProduct(ProductUpdate product) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.put(
      Uri.parse(updateProductInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Ürün güncellenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<bool> uploadMainImageToProduct(int productId, File image) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/Farmer/UploadImageToProduct?productId=$productId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    var pic = await http.MultipartFile.fromPath(
      "formFile",
      image.path,
      contentType: MediaType('image', 'jpeg'),  // uygun content type belirtin
    );

    request.files.add(pic);

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Ana resim başarıyla yüklendi');
      return true;
    } else {
      print('Ana resim yükleme başarısız: ${response.statusCode}');
      return false;
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
