import 'dart:convert';
import 'dart:io';
import 'package:fistikpazar/models/addproduct_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'https://api.fistikpazar.com/api';

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Farmer/GetCategory'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['categories']);
    } else {
      throw Exception('Kategoriler alınamadı!');
    }
  }

  static Future<List<Map<String, dynamic>>> getFields() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Farmer/GetField'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['fields']);
    } else {
      throw Exception('Tarlalar alınamadı!');
    }
  }

  static Future<bool> addProduct(Product product, File? mainImage, List<File>? extraImages) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Farmer/AddProduct'),
      headers: await _getHeaders(),
      body: jsonEncode(product.toJson()),
    );

    print('Request body: ${jsonEncode(product.toJson())}');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['productId'] != null) {
        bool mainImageUploadResult = true;
        if (mainImage != null) {
          mainImageUploadResult = await uploadMainImageToProduct(data['productId'], mainImage);
        }
        bool extraImagesUploadResult = true;
        if (extraImages != null && extraImages.isNotEmpty) {
          extraImagesUploadResult = await uploadExtraImagesToProduct(data['productId'], extraImages);
        }
        return mainImageUploadResult && extraImagesUploadResult;
      }
      return data['message'] == 'Ürün başarıyla eklendi.';
    } else {
      return false;
    }
  }

  static Future<bool> uploadMainImageToProduct(int productId, File image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

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

  static Future<bool> uploadExtraImagesToProduct(int productId, List<File> images) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Farmer/UploadMultipleImagesToProduct?productId=$productId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    for (var image in images) {
      var pic = await http.MultipartFile.fromPath(
        "formFiles",
        image.path,
        contentType: MediaType('image', 'jpeg'),  // uygun content type belirtin
      );
      request.files.add(pic);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Ek resimler başarıyla yüklendi');
      return true;
    } else {
      print('Ek resim yükleme başarısız: ${response.statusCode}');
      return false;
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
